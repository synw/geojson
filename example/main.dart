import 'dart:io';
import 'package:geojson/geojson.dart';

// data is from http://www.naturalearthdata.com

void main() async {
  final file = File("railroads_of_north_america.geojson");
  multipolygons(file);
  lines(file);
}

void multipolygons(File file) async {
  final file = File("lakes_of_europe.geojson");
  final features = await featuresFromGeoJsonFile(file, nameProperty: "label");
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

void lines(File file) async {
  final file = File("railroads_of_north_america.geojson");
  final features = await featuresFromGeoJsonFile(file);
  for (final feature in features.collection) {
    print("${feature.geometry.geoSerie.name}: " +
        "${feature.geometry.geoSerie.geoPoints.length} geopoints");
  }
}
