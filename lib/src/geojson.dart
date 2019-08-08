import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:iso/iso.dart';
import 'models.dart';
import 'deserializers.dart';
import 'exceptions.dart';

/// The main geojson class
class GeoJson {
  /// Default constructor
  GeoJson()
      : features = <Feature>[],
        points = <Point>[],
        multipoints = <MultiPoint>[],
        lines = <Line>[],
        multilines = <MultiLine>[],
        polygons = <Polygon>[],
        multipolygons = <MultiPolygon>[],
        _processedFeaturesController = StreamController<Feature>(),
        _processedPointsController = StreamController<Point>(),
        _processedMultipointsController = StreamController<MultiPoint>(),
        _processedLinesController = StreamController<Line>(),
        _processedMultilinesController = StreamController<MultiLine>(),
        _processedPolygonsController = StreamController<Polygon>(),
        _processedMultipolygonsController = StreamController<MultiPolygon>(),
        _endSignalController = StreamController<bool>();

  /// All the features
  List<Feature> features;

  /// All the points
  List<Point> points;

  /// All the multipoints
  List<MultiPoint> multipoints;

  /// All the lines
  List<Line> lines;

  /// All the multilines
  List<MultiLine> multilines;

  /// All the polygons
  List<Polygon> polygons;

  /// All the multipolygons
  List<MultiPolygon> multipolygons;

  StreamController<Feature> _processedFeaturesController;
  StreamController<Point> _processedPointsController;
  StreamController<MultiPoint> _processedMultipointsController;
  StreamController<Line> _processedLinesController;
  StreamController<MultiLine> _processedMultilinesController;
  StreamController<Polygon> _processedPolygonsController;
  StreamController<MultiPolygon> _processedMultipolygonsController;
  StreamController<bool> _endSignalController;

  /// Stream of features that are coming in as they are parsed
  /// Useful for handing the featues faster if the file is big
  Stream<Feature> get processedFeatures => _processedFeaturesController.stream;

  /// Stream of points that are coming in as they are parsed
  Stream<Point> get processedPoints => _processedPointsController.stream;

  /// Stream of multipoints that are coming in as they are parsed
  Stream<MultiPoint> get processedMultipoints =>
      _processedMultipointsController.stream;

  /// Stream of lines that are coming in as they are parsed
  Stream<Line> get processedLines => _processedLinesController.stream;

  /// Stream of multilines that are coming in as they are parsed
  Stream<MultiLine> get processedMultilines =>
      _processedMultilinesController.stream;

  /// Stream of polygons that are coming in as they are parsed
  Stream<Polygon> get processedPolygons => _processedPolygonsController.stream;

  /// Stream of multipolygons that are coming in as they are parsed
  Stream<MultiPolygon> get processedMultipolygons =>
      _processedMultipolygonsController.stream;

  /// The stream indicating that the parsing is finished
  /// Use it to dispose the class if not needed anymore after parsing
  Stream<bool> get endSignal => _endSignalController.stream;

  /// Parse the data from a file
  Future<void> parseFile(String path,
      {String nameProperty, bool verbose}) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw ("The file ${file.path} does not exist");
    }
    String data;
    try {
      data = await file.readAsString();
    } catch (e) {
      throw ("Can not read file $e");
    }
    if (verbose) {
      print("Parsing file ${file.path}");
    }
    await parse(data, nameProperty: nameProperty, verbose: verbose);
  }

  /// Parse the data
  Future<void> parse(String data, {String nameProperty, bool verbose}) async {
    final finished = Completer<Null>();
    Iso iso;
    iso = Iso(_processFeatures, onDataOut: (dynamic data) {
      if (data is Feature) {
        switch (data.type) {
          case FeatureType.point:
            final item = data.geometry as Point;
            points.add(item);
            _processedPointsController.sink.add(item);
            break;
          case FeatureType.multipoint:
            final item = data.geometry as MultiPoint;
            multipoints.add(item);
            _processedMultipointsController.sink.add(item);
            break;
          case FeatureType.line:
            final item = data.geometry as Line;
            lines.add(item);
            _processedLinesController.sink.add(item);
            break;
          case FeatureType.multiline:
            final item = data.geometry as MultiLine;
            multilines.add(item);
            _processedMultilinesController.sink.add(item);
            break;
          case FeatureType.polygon:
            final item = data.geometry as Polygon;
            polygons.add(item);
            _processedPolygonsController.sink.add(item);
            break;
          case FeatureType.multipolygon:
            final item = data.geometry as MultiPolygon;
            multipolygons.add(item);
            _processedMultipolygonsController.sink.add(item);
        }
        _processedFeaturesController.sink.add(data);
        features.add(data);
      } else {
        iso.dispose();
        finished.complete();
      }
    }, onError: (dynamic e) {
      print("ERROR $e / ${e.runtimeType}");
      throw (e);
    });
    final dataToProcess = _DataToProcess(
        data: data, nameProperty: nameProperty, verbose: verbose);
    unawaited(iso.run(<dynamic>[dataToProcess]));
    await finished.future;
    _endSignalController.sink.add(true);
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

  static void _processFeatures(IsoRunner iso) {
    final List<dynamic> args = iso.args;
    final dataToProcess = args[0] as _DataToProcess;
    final String data = dataToProcess.data;
    final String nameProperty = dataToProcess.nameProperty;
    final bool verbose = dataToProcess.verbose;
    final Map<String, dynamic> decoded =
        json.decode(data) as Map<String, dynamic>;
    final feats = decoded["features"] as List<dynamic>;
    for (final dfeature in feats) {
      final feat = dfeature as Map<String, dynamic>;
      var properties = <String, dynamic>{};
      if (feat.containsKey("properties")) {
        properties = feat["properties"] as Map<String, dynamic>;
      }
      final geometry = feat["geometry"] as Map<String, dynamic>;
      final geomType = geometry["type"].toString();
      Feature feature;
      switch (geomType) {
        case "MultiPolygon":
          feature = Feature<MultiPolygon>();
          feature.properties = properties;
          feature.type = FeatureType.multipolygon;
          feature.geometry = getMultipolygon(
              feature: feature,
              nameProperty: nameProperty,
              coordinates: geometry["coordinates"] as List<dynamic>);
          break;
        case "Polygon":
          feature = Feature<Polygon>();
          feature.properties = properties;
          feature.type = FeatureType.polygon;
          feature.geometry = getPolygon(
              feature: feature,
              nameProperty: nameProperty,
              coordinates: geometry["coordinates"] as List<dynamic>);
          break;
        case "MultiLineString":
          feature = Feature<MultiLine>();
          feature.properties = properties;
          feature.type = FeatureType.multiline;
          feature.geometry = getMultiLine(
              feature: feature,
              nameProperty: nameProperty,
              coordinates: geometry["coordinates"] as List<dynamic>);
          break;
        case "LineString":
          feature = Feature<Line>();
          feature.properties = properties;
          feature.type = FeatureType.line;
          feature.geometry = getLine(
              feature: feature,
              nameProperty: nameProperty,
              coordinates: geometry["coordinates"] as List<dynamic>);
          break;
        case "MultiPoint":
          feature = Feature<MultiPoint>();
          feature.properties = properties;
          feature.type = FeatureType.multipoint;
          feature.geometry = getMultiPoint(
              feature: feature,
              nameProperty: nameProperty,
              coordinates: geometry["coordinates"] as List<dynamic>);
          break;
        case "Point":
          feature = Feature<Point>();
          feature.properties = properties;
          feature.type = FeatureType.point;
          feature.geometry = getPoint(
              feature: feature,
              nameProperty: nameProperty,
              coordinates: geometry["coordinates"] as List<dynamic>);
          break;
        default:
          final e = FeatureNotSupported(geomType);
          throw (e);
      }
      iso.send(feature);
      if (verbose == true) {
        print("${feature.geometry.name} ${feature.type} : " +
            "${feature.length} points");
      }
    }
    iso.send("end");
  }
}

class _DataToProcess {
  _DataToProcess(
      {@required this.data,
      @required this.nameProperty,
      @required this.verbose});

  final String data;
  final String nameProperty;
  final bool verbose;
}
