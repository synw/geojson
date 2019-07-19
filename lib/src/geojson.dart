import 'dart:io';
import 'dart:convert';
import 'package:geopoint/geopoint.dart';

/// Get a [GeoSerie] list from a geojson string
Future<List<GeoSerie>> geoSerieFromGeoJson(String data,
    {String nameProperty = "name",
    GeoSerieType type = GeoSerieType.group,
    bool verbose = false}) async {
  final result = <GeoSerie>[];
  final Map<String, dynamic> decoded =
      json.decode(data) as Map<String, dynamic>;
  final features = decoded["features"] as List<dynamic>;
  for (final dfeature in features) {
    final feature = dfeature as Map<String, dynamic>;
    final properties = feature["properties"] as Map<String, dynamic>;
    final geometry = feature["geometry"] as Map<String, dynamic>;
    final name = properties[nameProperty].toString();
    List<dynamic> coordsList;
    final geomType = geometry["type"].toString();
    final geoPoints = <GeoPoint>[];
    if (geomType == "MultiPolygon") {
      final coordsL1 = geometry["coordinates"] as List<dynamic>;
      final coordsL2 = coordsL1[0] as List<dynamic>;
      coordsList = coordsL2[0] as List<dynamic>;
      type = GeoSerieType.polygon;
    } else if (geomType == "LineString") {
      coordsList = geometry["coordinates"] as List<dynamic>;
      type = GeoSerieType.line;
    }
    for (final coord in coordsList) {
      final geoPoint = GeoPoint(
          latitude: double.parse(coord[0].toString()),
          longitude: double.parse(coord[1].toString()));
      geoPoints.add(geoPoint);
    }
    final geoSerie = GeoSerie(name: name, type: type, geoPoints: geoPoints);
    result.add(geoSerie);
    if (verbose) {
      print("${geoSerie.name}: ${geoSerie.geoPoints.length} geopoints");
    }
  }
  return result;
}

/// Get a list of [GeoSerie] from a geojson file
Future<List<GeoSerie>> geoSerieFromGeoJsonFile(File file,
    {String nameProperty = "name",
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
  return geoSerieFromGeoJson(data);
}
