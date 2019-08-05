import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:pedantic/pedantic.dart';
import 'package:iso/iso.dart';
import 'package:meta/meta.dart';
import 'models.dart';
import 'deserializers.dart';
import 'exceptions.dart';

/// Get a feature collection from a geojson string
Future<FeatureCollection> featuresFromGeoJson(String data,
    {String nameProperty, bool verbose = false}) async {
  FeatureCollection featureCollection;
  final finished = Completer<Null>();
  Iso iso;
  iso = Iso(_processFeatures, onDataOut: (dynamic data) {
    final _result = data as FeatureCollection;
    featureCollection = _result;
    iso.dispose();
    finished.complete();
  }, onError: (dynamic e) {
    print("ERROR $e / ${e.runtimeType}");
    throw (e);
  });
  final dataToProcess =
      _DataToProcess(data: data, nameProperty: nameProperty, verbose: verbose);
  unawaited(iso.run(<dynamic>[dataToProcess]));
  await finished.future;
  return featureCollection;
}

/// Get a feature collection from a geojson file
Future<FeatureCollection> featuresFromGeoJsonFile(File file,
    {String nameProperty, bool verbose = false}) async {
  FeatureCollection features;
  if (!file.existsSync()) {
    throw ("File ${file.path} does not exist");
  }
  String data;
  try {
    data = await file.readAsString();
  } catch (e) {
    throw ("Can not read file $e");
  }
  features = await featuresFromGeoJson(data, verbose: verbose);
  return features;
}

void _processFeatures(IsoRunner iso) {
  final List<dynamic> args = iso.args;
  final dataToProcess = args[0] as _DataToProcess;
  final String data = dataToProcess.data;
  final String nameProperty = dataToProcess.nameProperty;
  final bool verbose = dataToProcess.verbose;
  final featuresCollection =
      _featuresFromGeoJson(data, nameProperty: nameProperty, verbose: verbose);
  iso.send(featuresCollection);
}

FeatureCollection _featuresFromGeoJson(String data,
    {String nameProperty, bool verbose = false}) {
  final features = FeatureCollection();
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
    features.collection.add(feature);
  }
  return features;
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
