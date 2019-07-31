import 'dart:io';
import 'package:geojson/geojson.dart';

// data is from http://www.naturalearthdata.com

void main() async {
  await smallData();
  await multipolygons();
  await lines();
}

Future<void> smallData() async {
  final file = File("small_data.geojson");
  final features = await featuresFromGeoJsonFile(file, verbose: true);
  for (final feature in features.collection) {
    print("Point: ${feature.geometry.geoPoint.name}");
  }
  return;
}

Future<void> multipolygons() async {
  final file = File("lakes_of_europe.geojson");
  final features =
      await featuresFromGeoJsonFile(file, nameProperty: "label", verbose: true);
  for (final feature in features.collection) {
    final geom = feature.geometry as MultiPolygon;
    for (final polygon in geom.polygons) {
      print("Polygon ${polygon.name}");
      for (final geoSerie in polygon.geoSeries) {
        print("- ${geoSerie.geoPoints.length} geopoints");
      }
    }
  }
}

Future<void> lines() async {
  final file = File("railroads_of_north_america.geojson");
  final features = await featuresFromGeoJsonFile(file, verbose: true);
  for (final feature in features.collection) {
    print("${feature.geometry.geoSerie.name}: " +
        "${feature.geometry.geoSerie.geoPoints.length} geopoints");
  }
}
