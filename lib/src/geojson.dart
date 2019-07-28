import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'models.dart';
import 'deseriializers.dart';

/// Get a feature collection from a geojson string
FeatureCollection featuresFromGeoJson(String data,
    {String nameProperty, bool verbose = false}) {
  final features = FeatureCollection();
  final Map<String, dynamic> decoded =
      json.decode(data) as Map<String, dynamic>;
  final feats = decoded["features"] as List<dynamic>;
  for (final dfeature in feats) {
    final feat = dfeature as Map<String, dynamic>;
    final properties = feat["properties"] as Map<String, dynamic>;
    final geometry = feat["geometry"] as Map<String, dynamic>;
    final geomType = geometry["type"].toString();
    final feature = Feature();
    feature.properties = properties;
    switch (geomType) {
      case "MultiPolygon":
        feature.type = FeatureType.multipolygon;
        feature.geometry = getMultipolygon(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
      case "Polygon":
        feature.type = FeatureType.polygon;
        feature.geometry = getPolygon(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
      case "MultiLineString":
        feature.type = FeatureType.multiline;
        feature.geometry = getMultiLine(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
      case "LineString":
        feature.type = FeatureType.line;
        feature.geometry = getLine(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
      case "MultiPoint":
        feature.type = FeatureType.multipoint;
        feature.geometry = getMultiPoint(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
      case "Point":
        feature.type = FeatureType.point;
        feature.geometry = getPoint(
            feature: feature,
            nameProperty: nameProperty,
            coordinates: geometry["coordinates"] as List<dynamic>);
        break;
      default:
    }
    if (feature.type != null) {
      features.collection.add(feature);
    }
  }
  return features;
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
  features = featuresFromGeoJson(data, verbose: verbose);
  return features;
}

/*
/// Get a [GeoSerie] list from a geojson string
Future<List<GeoSerie>> geoSerieFromGeoJson(String data,
    {String nameProperty,
    GeoSerieType type = GeoSerieType.group,
    bool verbose = false}) async {
  final result = <GeoSerie>[];
  final Map<String, dynamic> decoded =
      json.decode(data) as Map<String, dynamic>;
  var i = 1;
  final features = decoded["features"] as List<dynamic>;
  for (final dfeature in features) {
    final feature = dfeature as Map<String, dynamic>;
    final properties = feature["properties"] as Map<String, dynamic>;
    final geometry = feature["geometry"] as Map<String, dynamic>;
    List<dynamic> coordsList;
    final geomType = geometry["type"].toString();
    final geoPoints = <GeoPoint>[];
    String geomTypeLabel;
    if (geomType == "MultiPolygon") {
      geomTypeLabel = "Polygon";
      final coordsL1 = geometry["coordinates"] as List<dynamic>;
      final coordsL2 = coordsL1[0] as List<dynamic>;
      coordsList = coordsL2[0] as List<dynamic>;
      type = GeoSerieType.polygon;
    } else if (geomType == "LineString") {
      geomTypeLabel = "Line";
      coordsList = geometry["coordinates"] as List<dynamic>;
      type = GeoSerieType.line;
    }
    for (final coord in coordsList) {
      final geoPoint = GeoPoint(
          latitude: double.parse(coord[0].toString()),
          longitude: double.parse(coord[1].toString()));
      geoPoints.add(geoPoint);
    }
    String name;
    if (nameProperty != null) {
      name = properties[nameProperty].toString();
    } else {
      name = "$geomTypeLabel $i";
    }
    final geoSerie = GeoSerie(name: name, type: type, geoPoints: geoPoints);
    result.add(geoSerie);
    if (verbose) {
      print("${geoSerie.name}: ${geoSerie.geoPoints.length} geopoints");
    }
    ++i;
  }
  return result;
}

/// Get a list of [GeoSerie] from a geojson file
Future<List<GeoSerie>> geoSerieFromGeoJsonFile(File file,
    {String nameProperty,
    GeoSerieType type = GeoSerieType.group,
    bool verbose = false}) async {
  if (!file.existsSync()) {
    throw ("File ${file.path} does not exist");
  }
  String data;
  try {
    data = await file.readAsString();
  } catch (e) {
    throw ("Can not read file $e");
  }
  return geoSerieFromGeoJson(data,
      nameProperty: nameProperty, type: type, verbose: verbose);
}
*/
