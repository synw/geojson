import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geodesy/geodesy.dart';
import 'package:iso/iso.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import 'deserializers.dart';
import 'exceptions.dart';
import 'models.dart';

/// The main geojson class
class GeoJson {
  /// Default constructor
  GeoJson()
      : features = <GeoJsonFeature>[],
        points = <GeoJsonPoint>[],
        multipoints = <GeoJsonMultiPoint>[],
        lines = <GeoJsonLine>[],
        multilines = <GeoJsonMultiLine>[],
        polygons = <GeoJsonPolygon>[],
        multipolygons = <GeoJsonMultiPolygon>[],
        _processedFeaturesController = StreamController<GeoJsonFeature>(),
        _processedPointsController = StreamController<GeoJsonPoint>(),
        _processedMultipointsController = StreamController<GeoJsonMultiPoint>(),
        _processedLinesController = StreamController<GeoJsonLine>(),
        _processedMultilinesController = StreamController<GeoJsonMultiLine>(),
        _processedPolygonsController = StreamController<GeoJsonPolygon>(),
        _processedMultipolygonsController =
            StreamController<GeoJsonMultiPolygon>(),
        _endSignalController = StreamController<bool>();

  /// All the features
  List<GeoJsonFeature> features;

  /// All the points
  List<GeoJsonPoint> points;

  /// All the multipoints
  List<GeoJsonMultiPoint> multipoints;

  /// All the lines
  List<GeoJsonLine> lines;

  /// All the multilines
  List<GeoJsonMultiLine> multilines;

  /// All the polygons
  List<GeoJsonPolygon> polygons;

  /// All the multipolygons
  List<GeoJsonMultiPolygon> multipolygons;

  final StreamController<GeoJsonFeature> _processedFeaturesController;
  final StreamController<GeoJsonPoint> _processedPointsController;
  final StreamController<GeoJsonMultiPoint> _processedMultipointsController;
  final StreamController<GeoJsonLine> _processedLinesController;
  final StreamController<GeoJsonMultiLine> _processedMultilinesController;
  final StreamController<GeoJsonPolygon> _processedPolygonsController;
  final StreamController<GeoJsonMultiPolygon> _processedMultipolygonsController;
  final StreamController<bool> _endSignalController;

  /// Stream of features that are coming in as they are parsed
  /// Useful for handing the featues faster if the file is big
  Stream<GeoJsonFeature> get processedFeatures =>
      _processedFeaturesController.stream;

  /// Stream of points that are coming in as they are parsed
  Stream<GeoJsonPoint> get processedPoints => _processedPointsController.stream;

  /// Stream of multipoints that are coming in as they are parsed
  Stream<GeoJsonMultiPoint> get processedMultipoints =>
      _processedMultipointsController.stream;

  /// Stream of lines that are coming in as they are parsed
  Stream<GeoJsonLine> get processedLines => _processedLinesController.stream;

  /// Stream of multilines that are coming in as they are parsed
  Stream<GeoJsonMultiLine> get processedMultilines =>
      _processedMultilinesController.stream;

  /// Stream of polygons that are coming in as they are parsed
  Stream<GeoJsonPolygon> get processedPolygons =>
      _processedPolygonsController.stream;

  /// Stream of multipolygons that are coming in as they are parsed
  Stream<GeoJsonMultiPolygon> get processedMultipolygons =>
      _processedMultipolygonsController.stream;

  /// The stream indicating that the parsing is finished
  /// Use it to dispose the class if not needed anymore after parsing
  Stream<bool> get endSignal => _endSignalController.stream;

  /// Parse the data from a file
  Future<void> parseFile(String path,
      {String nameProperty,
      bool verbose = false,
      GeoJsonQuery query,
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
      {String nameProperty,
      bool verbose = false,
      bool disableStream = false}) async {
    return _parse(data,
        nameProperty: nameProperty,
        verbose: verbose,
        disableStream: disableStream);
  }

  Future<void> _parse(String data,
      {String nameProperty,
      bool verbose,
      GeoJsonQuery query,
      bool disableStream}) async {
    final finished = Completer<void>();
    Iso iso;
    iso = Iso(_processFeatures, onDataOut: (dynamic data) {
      if (data is GeoJsonFeature) {
        switch (data.type) {
          case GeoJsonFeatureType.point:
            final item = data.geometry as GeoJsonPoint;
            points.add(item);
            if (!disableStream) {
              _processedPointsController.sink.add(item);
            }
            break;
          case GeoJsonFeatureType.multipoint:
            final item = data.geometry as GeoJsonMultiPoint;
            multipoints.add(item);
            if (!disableStream) {
              _processedMultipointsController.sink.add(item);
            }
            break;
          case GeoJsonFeatureType.line:
            final item = data.geometry as GeoJsonLine;
            lines.add(item);
            if (!disableStream) {
              _processedLinesController.sink.add(item);
            }
            break;
          case GeoJsonFeatureType.multiline:
            final item = data.geometry as GeoJsonMultiLine;
            multilines.add(item);
            if (!disableStream) {
              _processedMultilinesController.sink.add(item);
            }
            break;
          case GeoJsonFeatureType.polygon:
            final item = data.geometry as GeoJsonPolygon;
            polygons.add(item);
            if (!disableStream) {
              _processedPolygonsController.sink.add(item);
            }
            break;
          case GeoJsonFeatureType.multipolygon:
            final item = data.geometry as GeoJsonMultiPolygon;
            multipolygons.add(item);
            if (!disableStream) {
              _processedMultipolygonsController.sink.add(item);
            }
            break;
          case GeoJsonFeatureType.geometryCollection:
        }
        if (!disableStream) {
          _processedFeaturesController.sink.add(data);
        }
        features.add(data);
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

  /// Search a [GeoJsonFeature] by prpperty from a file
  Future<void> searchInFile(String path,
      {@required GeoJsonQuery query,
      String nameProperty,
      bool verbose = false}) async {
    await parseFile(path,
        nameProperty: nameProperty, verbose: verbose, query: query);
  }

  /// Search a [GeoJsonFeature] by prpperty.
  ///
  /// If the string data is not provided the existing features will be used
  /// to search
  Future<void> search(String data,
      {@required GeoJsonQuery query,
      String nameProperty,
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
      {@required GeoJsonPoint point,
      @required List<GeoJsonPoint> points,
      @required num distance,
      bool disableStream = false,
      bool verbose = false}) async {
    final foundPoints = <GeoJsonPoint>[];
    final finished = Completer<void>();
    Iso iso;
    iso = Iso(_geoFenceDistanceRunner, onDataOut: (dynamic data) {
      if (data is GeoJsonPoint) {
        final point = data;
        foundPoints.add(point);
        if (!disableStream) {
          _processedPointsController.sink.add(point);
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
    final args = iso.args;
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
      {@required GeoJsonPolygon polygon,
      @required List<GeoJsonPoint> points,
      bool disableStream = false,
      bool verbose = false}) async {
    final foundPoints = <GeoJsonPoint>[];
    final finished = Completer<void>();
    Iso iso;
    iso = Iso(_geofencePolygonRunner, onDataOut: (dynamic data) {
      if (data is GeoJsonPoint) {
        final point = data;
        foundPoints.add(point);
        if (!disableStream) {
          _processedPointsController.sink.add(point);
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
    final args = iso.args;
    final dataToProcess = args[0] as _GeoFenceToProcess;
    final points = dataToProcess.points;
    final polygon = dataToProcess.polygon;
    final verbose = dataToProcess.verbose;
    final geodesy = Geodesy();
    final geoFencedPoints = <GeoJsonPoint>[];
    for (final point in points) {
      for (final geoSerie in polygon.geoSeries) {
        if (geodesy.isGeoPointInPolygon(
            point.geoPoint.toLatLng(ignoreErrors: true),
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
    _processedPointsController.close();
    _processedMultipointsController.close();
    _processedLinesController.close();
    _processedMultilinesController.close();
    _processedPolygonsController.close();
    _processedMultipointsController.close();
    _endSignalController.close();
  }

  static GeoJsonFeature _processGeometry(Map<String, dynamic> geometry,
      Map<String, dynamic> properties, String nameProperty) {
    final geomType = geometry["type"].toString();
    GeoJsonFeature feature;
    switch (geomType) {
      case "MultiPolygon":
        feature = GeoJsonFeature<GeoJsonMultiPolygon>();
        feature.properties = properties;
        feature.type = GeoJsonFeatureType.multipolygon;
        feature.geometry = getMultipolygon(
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
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
    }
    return feature;
  }

  static void _processFeatures(IsoRunner iso) {
    final args = iso.args;
    final dataToProcess = args[0] as _DataToProcess;
    final data = dataToProcess.data;
    final nameProperty = dataToProcess.nameProperty;
    final verbose = dataToProcess.verbose;
    final query = dataToProcess.query;
    final decoded = json.decode(data) as Map<String, dynamic>;
    final feats = decoded["features"] as List<dynamic>;
    for (final dfeature in feats) {
      final feat = dfeature as Map<String, dynamic>;
      var properties = <String, dynamic>{};
      if (feat.containsKey("properties")) {
        properties = feat["properties"] as Map<String, dynamic>;
      }
      final geometry = feat["geometry"] as Map<String, dynamic>;
      final geomType = geometry["type"].toString();
      GeoJsonFeature feature;
      switch (geomType) {
        case "GeometryCollection":
          feature = GeoJsonFeature<GeoJsonGeometryCollection>()
            ..properties = properties
            ..type = GeoJsonFeatureType.geometryCollection
            ..geometry = GeoJsonGeometryCollection();
          if (nameProperty != null) {
            feature.geometry.name = properties[nameProperty];
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
      iso.send(feature);
      if (verbose == true) {
        print("${feature.type} ${feature.geometry.name} : "
            "${feature.length} points");
      }
    }
    iso.send("end");
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
            if (properties[query.property] != value) {
              isPropertyOk = false;
            }
            break;
          case GeoSearchType.startsWith:
            final prop = properties[query.property] as String;
            if (!prop.startsWith(value)) {
              isPropertyOk = false;
            }
            break;
          case GeoSearchType.contains:
            final prop = properties[query.property] as String;
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
      {@required this.data,
      @required this.nameProperty,
      @required this.verbose,
      @required this.query});

  final String data;
  final String nameProperty;
  final bool verbose;
  final GeoJsonQuery query;
}

class _GeoFenceToProcess {
  _GeoFenceToProcess(
      {@required this.points, @required this.polygon, @required this.verbose});

  final bool verbose;
  final GeoJsonPolygon polygon;
  final List<GeoJsonPoint> points;
}

class _GeoFenceDistanceToProcess {
  _GeoFenceDistanceToProcess(
      {@required this.points,
      @required this.point,
      @required this.distance,
      @required this.verbose});

  final bool verbose;
  final num distance;
  final List<GeoJsonPoint> points;
  final GeoJsonPoint point;
}
