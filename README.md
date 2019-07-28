# Geojson

[![pub package](https://img.shields.io/pub/v/geojson.svg)](https://pub.dartlang.org/packages/geojson)

Utilities to work with geojson data in Dart.

## Example

```dart
import 'dart:io';
import 'package:geojson/geojson.dart';

void main() async {
  multipolygons();
  lines();
}

void multipolygons() async {
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

void lines() async {
  final file = File("railroads_of_north_america.geojson");
  final features = await featuresFromGeoJsonFile(file);
  for (final feature in features.collection) {
    print("${feature.geometry.geoSerie.name}: " +
        "${feature.geometry.geoSerie.geoPoints.length} geopoints");
  }
}

```

## Api

`geoSerieFromGeoJson`: create geoseries from geojson string data. Parameters:

- `data`: a string with the geojson data, required
- `nameProperty`: the property used for the geoserie name, automaticaly set if null
- `type`: the geoserie type, infered from data if not provided
- `verbose`: print data if true

`geoSerieFromGeoJsonFile`: create geoseries from a geojson file. Parameters:

- `file`: the file to load, required
- `nameProperty`: the property used for the geoserie name, automaticaly set if null
- `type`: the geoserie type, infered from the file if not provided
- `verbose`: print data if true
