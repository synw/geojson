# Geojson

[![pub package](https://img.shields.io/pub/v/geojson.svg)](https://pub.dartlang.org/packages/geojson)

Utilities to work with geojson data in Dart.

**Note**: the api is currently discussed and improved and may change

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

`featuresFromGeoJson`: get a `FeaturesCollection` from geojson string data. Parameters:

- `data`: a string with the geojson data, required
- `nameProperty`: the property used for the geoserie name, automaticaly set if null
- `verbose`: print data if true

`featuresFromGeoJsonFile`: get a `FeaturesCollection` from a geojson file. Parameters:

- `file`: the file to load, required
- `nameProperty`: the property used for the geoserie name, automaticaly set if null
- `verbose`: print data if true

## Supported geojson features

All the data structures use `GeoPoint` and `GeoSerie` from the [GeoPoint](https://github.com/synw/geopoint) package to store the geometry data. Data structures used:

**FeatureCollection**:

- `String` **name**
- `List<Feature>` **collection**

**Feature**:

- `FeatureType` **type**: one of `FeatureType.point`, `FeatureType.multipoint`, `FeatureType.line`, `FeatureType.multiline`, `FeatureType.polygon`, `FeatureType.multipolygon`
- `Map<String, dynamic>` **properties**: the json properties of the feature
- `dynamic` **geometry**: the geometry data, depends on the feature type, see below

**Point**:

- `String` **name**
- `GeoPoint` **geoPoint**: the geometry data

**MultiPoint**:

- `String` **name**
- `GeoSerie` **geoSerie**: the geometry data: this will produce a geoSerie of type `GeoSerieType.group`

**Line**:

- `String` **name**
- `GeoSerie` **geoSerie**: the geometry data: this will produce a geoSerie of type `GeoSerieType.line`

**MultiLine**:

- `String` **name**
- `List<Line>` **lines**

**Polygon**:

- `String` **name**
- `List<GeoSerie>` **geoSeries**: the geometry data: this will produce a list of geoSerie of type `GeoSerieType.polygon`*

**MultiPolygon**:

- `String` **name**
- `List<Polygon>` **polygons**

Note: none of the parameters is final for all of these data structures
