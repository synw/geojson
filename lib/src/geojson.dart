import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geodesy/geodesy.dart';
import 'package:iso/iso.dart';
import 'package:pedantic/pedantic.dart';

import 'deserializers.dart';
import 'exceptions.dart';
import 'models.dart';

/// The main geojson class
class GeoJson {
  /// Default constructor
  GeoJson()
      : features = <GeoJsonFeature<dynamic>>[],
        points = <GeoJsonPoint>[],
        multiPoints = <GeoJsonMultiPoint>[],
        lines = <GeoJsonLine>[],
        multiLines = <GeoJsonMultiLine>[],
        polygons = <GeoJsonPolygon>[],
        multiPolygons = <GeoJsonMultiPolygon>[],
        _processedFeaturesController = StreamController<dynamic>.broadcast(),
        _endSignalController = StreamController<bool>();

  /// All the features
  List<GeoJsonFeature<dynamic>> features;

  /// All the points
  List<GeoJsonPoint> points;

  /// All the multi points
  List<GeoJsonMultiPoint> multiPoints;

  /// All the lines
  List<GeoJsonLine> lines;

  /// All the multi lines
  List<GeoJsonMultiLine> multiLines;

  /// All the polygons
  List<GeoJsonPolygon> polygons;

  /// All the multi polygons
  List<GeoJsonMultiPolygon> multiPolygons;

  ///
  final StreamController<dynamic> _processedFeaturesController;
  final StreamController<bool> _endSignalController;

  /// Stream of features that are coming in as they are parsed
  /// Useful for handing the features faster if the file is big
  Stream<GeoJsonFeature<dynamic>> get processedFeatures =>
      _getGeoStream<GeoJsonFeature<dynamic>>();

  /// Stream of points that are coming in as they are parsed
  Stream<GeoJsonPoint> get processedPoints => _getGeoStream<GeoJsonPoint>();

  /// Stream of multi points that are coming in as they are parsed
  Stream<GeoJsonMultiPoint> get processedMultiPoints =>
      _getGeoStream<GeoJsonMultiPoint>();

  /// Stream of lines that are coming in as they are parsed
  Stream<GeoJsonLine> get processedLines => _getGeoStream<GeoJsonLine>();

  /// Stream of multi lines that are coming in as they are parsed
  Stream<GeoJsonMultiLine> get processedMultiLines =>
      _getGeoStream<GeoJsonMultiLine>();

  /// Stream of polygons that are coming in as they are parsed
  Stream<GeoJsonPolygon> get processedPolygons =>
      _getGeoStream<GeoJsonPolygon>();

  /// Stream of multi polygons that are coming in as they are parsed
  Stream<GeoJsonMultiPolygon> get processedMultiPolygons =>
      _getGeoStream<GeoJsonMultiPolygon>();

  /// The stream indicating that the parsing is finished
  /// Use it to dispose the class if not needed anymore after parsing
  Stream<bool> get endSignal => _endSignalController.stream;
  // internal method
  Stream<T> _getGeoStream<T>() => _processedFeaturesController.stream
      .asBroadcastStream()
      .where((dynamic event) => event != null && event is T)
      .map((dynamic event) => event as T);

  /// Parse the data from a file
  Future<void> parseFile(String path,
      {String? nameProperty,
      bool verbose = false,
      GeoJsonQuery? query,
      bool disableStream = false}) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw FileSystemException("The file ${file.path} does not exist");
    }
    String data;
    try {
      data = await file.readAsString();
    } catch (e) {
      throw FileSystemException("Can not read file $e");
    }
    if (verbose) {
      print("Parsing file ${file.path}");
    }
    await _parse(data,
        nameProperty: nameProperty,
        verbose: verbose,
        query: query,
        disableStream: disableStream);
  }

  /// Parse the data
  Future<void> parse(String data,
          {String? nameProperty,
          bool verbose = false,
          bool disableStream = false}) =>
      _parse(data,
          nameProperty: nameProperty,
          verbose: verbose,
          disableStream: disableStream);

  void _pipeFeature(GeoJsonFeature<dynamic> data,
      {required bool disableStream}) {
    dynamic item;
    switch (data.type) {
      case GeoJsonFeatureType.point:
        item = data.geometry as GeoJsonPoint;
        if (item != null) points.add(data.geometry as GeoJsonPoint);
        break;
      case GeoJsonFeatureType.multipoint:
        item = data.geometry as GeoJsonMultiPoint;
        if (item != null) multiPoints.add(item as GeoJsonMultiPoint);
        break;
      case GeoJsonFeatureType.line:
        item = data.geometry as GeoJsonLine;
        if (item != null) lines.add(item as GeoJsonLine);
        break;
      case GeoJsonFeatureType.multiline:
        item = data.geometry as GeoJsonMultiLine;
        if (item != null) multiLines.add(item as GeoJsonMultiLine);
        break;
      case GeoJsonFeatureType.polygon:
        item = data.geometry as GeoJsonPolygon;
        if (item != null) polygons.add(item as GeoJsonPolygon);
        break;
      case GeoJsonFeatureType.multipolygon:
        item = data.geometry as GeoJsonMultiPolygon;
        if (item != null) multiPolygons.add(item as GeoJsonMultiPolygon);
        break;
      case GeoJsonFeatureType.geometryCollection:
    }
    if (!disableStream) {
      if (item != null) _processedFeaturesController.sink.add(item);
      _processedFeaturesController.sink.add(data);
    }
    features.add(data);
  }

  /// Parse the geojson in the main thread not using any isolate:
  /// necessary for the web
  Future<void> parseInMainThread(String data,
      {String? nameProperty,
      GeoJsonQuery? query,
      bool verbose = false,
      bool disableStream = false}) async {
    final dataToProcess = _DataToProcess(
        data: data, nameProperty: nameProperty, verbose: verbose, query: query);
    final _feats = StreamController<GeoJsonFeature<dynamic>?>();
    final _sub = _feats.stream.listen((f) {
      if (verbose) {
        print("FEAT SUB $f / ${f!.type}");
      }

      _pipeFeature(f!, disableStream: disableStream);
    });
    if (verbose) {
      print("Processing");
    }
    _processFeatures(dataToProcess: dataToProcess, sink: _feats.sink);
    if (verbose) {
      print("Closing");
    }

    await _feats.close();
    await _sub.cancel();
  }

  Future<void> _parse(
    String data, {
    required bool disableStream,
    required bool verbose,
    String? nameProperty,
    GeoJsonQuery? query,
  }) async {
    final finished = Completer<void>();
    late Iso iso;
    iso = Iso(_processFeaturesIso, onDataOut: (dynamic data) {
      if (data is GeoJsonFeature) {
        _pipeFeature(data, disableStream: disableStream);
      } else {
        iso.dispose();
        finished.complete();
      }
    }, onError: (dynamic e) {
      print("Error: $e");
      throw ParseErrorException("Can not parse geojson");
    });
    final dataToProcess = _DataToProcess(
        data: data, nameProperty: nameProperty, verbose: verbose, query: query);
    unawaited(iso.run(<dynamic>[dataToProcess]));
    await finished.future;
    _endSignalController.sink.add(true);
  }

  /// Search a [GeoJsonFeature] by property from a file
  Future<void> searchInFile(String path,
      {required GeoJsonQuery query,
      String? nameProperty,
      bool verbose = false}) async {
    await parseFile(path,
        nameProperty: nameProperty, verbose: verbose, query: query);
  }

  /// Search a [GeoJsonFeature] by property.
  ///
  /// If the string data is not provided the existing features will be used
  /// to search
  Future<void> search(String? data,
      {required GeoJsonQuery query,
      String? nameProperty,
      bool verbose = false,
      bool disableStream = false}) async {
    if (data == null && features.isEmpty) {
      throw ArgumentError("Provide data or parse some to run a search");
    }
    if (data != null) {
      await _parse(data,
          nameProperty: nameProperty,
          verbose: verbose,
          query: query,
          disableStream: disableStream);
    }
  }

  /// Find all the [GeoJsonPoint] within a certain distance
  /// from a [GeoJsonPoint]
  Future<List<GeoJsonPoint>> geofenceDistance(
      {required GeoJsonPoint point,
      required List<GeoJsonPoint> points,
      required num distance,
      bool disableStream = false,
      bool verbose = false}) async {
    final foundPoints = <GeoJsonPoint>[];
    final finished = Completer<void>();
    late Iso iso;
    iso = Iso(_geoFenceDistanceRunner, onDataOut: (dynamic data) {
      if (data is GeoJsonPoint) {
        final point = data;
        foundPoints.add(point);
        if (!disableStream) {
          _processedFeaturesController.sink.add(point);
        }
      } else {
        iso.dispose();
        finished.complete();
      }
    }, onError: (dynamic e) {
      throw GeofencingException("Can not geofence $e");
    });
    final dataToProcess = _GeoFenceDistanceToProcess(
        points: points, point: point, distance: distance, verbose: verbose);
    unawaited(iso.run(<dynamic>[dataToProcess]));
    await finished.future;
    return foundPoints;
  }

  static Future<void> _geoFenceDistanceRunner(IsoRunner iso) async {
    final args = iso.args!;
    final dataToProcess = args[0] as _GeoFenceDistanceToProcess;
    final points = dataToProcess.points;
    final distance = dataToProcess.distance;
    final point = dataToProcess.point;
    final verbose = dataToProcess.verbose;
    final geodesy = Geodesy();
    for (final p in points) {
      final distanceFromCenter = geodesy.distanceBetweenTwoGeoPoints(
          point.geoPoint.point, p.geoPoint.point);
      if (distanceFromCenter <= distance) {
        if (verbose) {
          print("${p.name}");
        }
        iso.send(p);
      }
    }
    iso.send("end");
  }

  /// Find all the [GeoJsonPoint] located in a [GeoJsonPolygon]
  /// from a list of points
  Future<List<GeoJsonPoint>> geofencePolygon(
      {required GeoJsonPolygon polygon,
      required List<GeoJsonPoint> points,
      bool disableStream = false,
      bool verbose = false}) async {
    final foundPoints = <GeoJsonPoint>[];
    final finished = Completer<void>();
    late Iso iso;
    iso = Iso(_geofencePolygonRunner, onDataOut: (dynamic data) {
      if (data is GeoJsonPoint) {
        final point = data;
        foundPoints.add(point);
        if (!disableStream) {
          _processedFeaturesController.sink.add(point);
        }
      } else {
        iso.dispose();
        finished.complete();
      }
    }, onError: (dynamic e) {
      throw GeofencingException("Can not geofence polygon $e");
    });
    final dataToProcess =
        _GeoFenceToProcess(points: points, polygon: polygon, verbose: verbose);
    unawaited(iso.run(<dynamic>[dataToProcess]));
    await finished.future;
    return foundPoints;
  }

  static Future<void> _geofencePolygonRunner(IsoRunner iso) async {
    final args = iso.args!;
    final dataToProcess = args[0] as _GeoFenceToProcess;
    final points = dataToProcess.points;
    final polygon = dataToProcess.polygon;
    final verbose = dataToProcess.verbose;
    final geodesy = Geodesy();
    final geoFencedPoints = <GeoJsonPoint>[];
    for (final point in points) {
      for (final geoSerie in polygon.geoSeries) {
        if (geodesy.isGeoPointInPolygon(
            point.geoPoint.toLatLng(ignoreErrors: true)!,
            geoSerie.toLatLng(ignoreErrors: true))) {
          if (verbose) {
            print("- ${point.name}");
          }
          geoFencedPoints.add(point);
          iso.send(point);
        }
      }
    }
    iso.send("end");
  }

  /// Dispose the class when finished using it
  void dispose() {
    _processedFeaturesController.close();
    _endSignalController.close();
  }

  static GeoJsonFeature<dynamic>? _processGeometry(
      Map<String, dynamic> geometry,
      Map<String, dynamic>? properties,
      String? nameProperty) {
    final geomType = geometry["type"].toString();
    GeoJsonFeature<dynamic>? feature;
    switch (geomType) {
      case "GeometryCollection":
        feature = GeoJsonFeature<GeoJsonGeometryCollection>();
        feature.properties = properties;
        feature.type = GeoJsonFeatureType.geometryCollection;

        final geometries = <GeoJsonFeature<dynamic>?>[];
        for (final geom in geometry["geometries"] as List<dynamic>) {
          geometries.add(_processGeometry(
              geom as Map<String, dynamic>, properties, nameProperty));
        }

        feature.geometry = getGeometryCollection(
            feature: feature,
            nameProperty: nameProperty,
            geometries: geometries);
        break;
      case "MultiPolygon":
        feature = GeoJsonFeature<GeoJsonMultiPolygon>();
        feature.properties = properties;
        feature.type = GeoJsonFeatureType.multipolygon;
        feature.geometry = getMultiPolygon(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
      case "Polygon":
        feature = GeoJsonFeature<GeoJsonPolygon>();
        feature.properties = properties;
        feature.type = GeoJsonFeatureType.polygon;
        feature.geometry = getPolygon(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
      case "MultiLineString":
        feature = GeoJsonFeature<GeoJsonMultiLine>();
        feature.properties = properties;
        feature.type = GeoJsonFeatureType.multiline;
        feature.geometry = getMultiLine(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
      case "LineString":
        feature = GeoJsonFeature<GeoJsonLine>();
        feature.properties = properties;
        feature.type = GeoJsonFeatureType.line;
        feature.geometry = getLine(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
      case "MultiPoint":
        feature = GeoJsonFeature<GeoJsonMultiPoint>();
        feature.properties = properties;
        feature.type = GeoJsonFeatureType.multipoint;
        feature.geometry = getMultiPoint(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
      case "Point":
        feature = GeoJsonFeature<GeoJsonPoint>();
        feature.properties = properties;
        feature.type = GeoJsonFeatureType.point;
        feature.geometry = getPoint(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>?);
        break;
    }
    return feature;
  }

  static void _processFeaturesIso(IsoRunner iso) {
    final args = iso.args!;
    final dataToProcess = args[0] as _DataToProcess;
    _processFeatures(iso: iso, dataToProcess: dataToProcess);
  }

  static void _processFeatures(
      {required _DataToProcess dataToProcess,
      IsoRunner? iso,
      StreamSink<GeoJsonFeature<dynamic>?>? sink}) {
    if (iso == null) {
      if (sink == null) {
        throw ArgumentError.notNull();
      }
    }
    final data = dataToProcess.data;
    final nameProperty = dataToProcess.nameProperty;
    final verbose = dataToProcess.verbose;
    final query = dataToProcess.query;
    final decoded = json.decode(data) as Map<String, dynamic>;
    final feats = decoded["features"] as List<dynamic>;
    for (final dFeature in feats) {
      final feat = dFeature as Map<String, dynamic>;
      Map<String, dynamic>? properties = <String, dynamic>{};
      if (feat.containsKey("properties")) {
        properties = feat["properties"] as Map<String, dynamic>?;
      }
      final geometry = feat["geometry"] as Map<String, dynamic>;
      final geomType = geometry["type"].toString();
      GeoJsonFeature<dynamic>? feature;
      switch (geomType) {
        case "GeometryCollection":
          feature = GeoJsonFeature<GeoJsonGeometryCollection>()
            ..properties = properties
            ..type = GeoJsonFeatureType.geometryCollection
            ..geometry = GeoJsonGeometryCollection();
          if (nameProperty != null) {
            feature.geometry.name = properties![nameProperty];
          }
          for (final geom in geometry["geometries"]) {
            feature.geometry.add(_processGeometry(
                geom as Map<String, dynamic>, properties, nameProperty));
          }
          break;
        case "MultiPolygon":
          if (query != null) {
            if (query.geometryType != null) {
              if (query.geometryType != GeoJsonFeatureType.multipolygon) {
                continue;
              }
            }
          }
          feature = _processGeometry(geometry, properties, nameProperty);
          break;
        case "Polygon":
          if (query != null) {
            if (query.geometryType != null) {
              if (query.geometryType != GeoJsonFeatureType.polygon) {
                continue;
              }
            }
          }
          feature = _processGeometry(geometry, properties, nameProperty);
          break;
        case "MultiLineString":
          if (query != null) {
            if (query.geometryType != null) {
              if (query.geometryType != GeoJsonFeatureType.multiline) {
                continue;
              }
            }
          }
          feature = _processGeometry(geometry, properties, nameProperty);
          break;
        case "LineString":
          if (query != null) {
            if (query.geometryType != null) {
              if (query.geometryType != GeoJsonFeatureType.line) {
                continue;
              }
            }
          }
          feature = _processGeometry(geometry, properties, nameProperty);
          break;
        case "MultiPoint":
          if (query != null) {
            if (query.geometryType != null) {
              if (query.geometryType != GeoJsonFeatureType.multipoint) {
                continue;
              }
            }
          }
          feature = _processGeometry(geometry, properties, nameProperty);
          break;
        case "Point":
          if (query != null) {
            if (query.geometryType != null) {
              if (query.geometryType != GeoJsonFeatureType.point) {
                continue;
              }
            }
          }
          feature = _processGeometry(geometry, properties, nameProperty);
          break;
        default:
          final e = FeatureNotSupported(geomType);
          throw e;
      }
      if (query != null && properties != null) {
        if (!_checkProperty(properties, query)) {
          continue;
        }
      }
      if (iso != null) {
        iso.send(feature);
      } else {
        if (verbose) {
          print("FEAT SINK $feature / ${feature?.type}");
        }
        sink?.add(feature);
      }
      if (verbose == true) {
        print("${feature?.type} ${feature?.geometry?.name} : "
            "${feature?.length} points");
      }
    }
    if (iso != null) {
      iso.send("end");
    }
  }

  static bool _checkProperty(
      Map<String, dynamic> properties, GeoJsonQuery query) {
    var isPropertyOk = true;
    if (query.property != null) {
      if (properties.containsKey(query.property)) {
        var value = query.value.toString();
        if (query.matchCase) {
          value = query.value.toString().toLowerCase();
        }
        switch (query.searchType) {
          case GeoSearchType.exact:
            if (properties[query.property!] != value) {
              isPropertyOk = false;
            }
            break;
          case GeoSearchType.startsWith:
            final prop = properties[query.property!] as String;
            if (!prop.startsWith(value)) {
              isPropertyOk = false;
            }
            break;
          case GeoSearchType.contains:
            final prop = properties[query.property!] as String;
            if (!prop.contains(value)) {
              isPropertyOk = false;
            }
            break;
        }
      }
    }
    return isPropertyOk;
  }
}

class _DataToProcess {
  _DataToProcess(
      {required this.data,
      required this.nameProperty,
      required this.verbose,
      required this.query});

  final String data;
  final String? nameProperty;
  final bool verbose;
  final GeoJsonQuery? query;
}

class _GeoFenceToProcess {
  _GeoFenceToProcess(
      {required this.points, required this.polygon, required this.verbose});

  final bool verbose;
  final GeoJsonPolygon polygon;
  final List<GeoJsonPoint> points;
}

class _GeoFenceDistanceToProcess {
  _GeoFenceDistanceToProcess(
      {required this.points,
      required this.point,
      required this.distance,
      required this.verbose});

  final bool verbose;
  final num distance;
  final List<GeoJsonPoint> points;
  final GeoJsonPoint point;
}
