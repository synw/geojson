import 'dart:io';
import 'package:geojson/geojson.dart';

// data is from http://www.naturalearthdata.com

void main() async {
  final file = File("railroads_of_north_america.geojson");
  polygons(file);
  lines(file);
}

void polygons(File file) async {
  final file = File("lakes_of_europe.geojson");
  final geoSeries = await geoSerieFromGeoJsonFile(file, nameProperty: "label");
  for (final geoSerie in geoSeries) {
    print("${geoSerie.name}: ${geoSerie.geoPoints.length} geopoints");
  }
}

void lines(File file) async {
  final file = File("railroads_of_north_america.geojson");
  final geoSeries =
      await geoSerieFromGeoJsonFile(file, nameProperty: "continent");
  for (final geoSerie in geoSeries) {
    print("${geoSerie.name}: ${geoSerie.geoPoints.length} geopoints");
  }
}
