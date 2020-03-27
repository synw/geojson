# Geojson

[![pub package](https://img.shields.io/pub/v/geojson.svg)](https://pub.dartlang.org/packages/geojson) [![Build Status](https://travis-ci.org/synw/geojson.svg?branch=master)](https://travis-ci.org/synw/geojson) [![Coverage Status](https://coveralls.io/repos/github/synw/geojson/badge.svg?branch=master)](https://coveralls.io/github/synw/geojson?branch=master)

Utilities to work with geojson data in Dart. Features:

- **Parser** with a **reactive api**: streams are available to retrieve the geojson features as soon as they are parsed
- **Search**: search for properties
- **Geofencing**: geofence points in a polygon or from a distance

Note: the data is parsed in an isolate to avoid slowing down the main thread

## Simple functions

**[featuresFromGeoJson](https://pub.dev/documentation/geojson/latest/geojson/featuresFromGeoJson.html)**: get a [FeaturesCollection](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonFeatureCollection-class.html) from geojson string data. Parameters:

- `data`: a string with the geojson data, required
- `nameProperty`: the property used for the geoserie name, automaticaly set if null
- `verbose`: print the parsed data if true

**[featuresFromGeoJsonFile](https://pub.dev/documentation/geojson/latest/geojson/featuresFromGeoJsonFile.html)**: get a [FeaturesCollection](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonFeatureCollection-class.html) from a geojson file. Parameters:

- `file`: the file to load, required
- `nameProperty`: the property used for the geoserie name, automaticaly set if null
- `verbose`: print the parsed data if true

These functions are suitable for small data. Example:

```dart
final features = await featuresFromGeoJson(data);
```

## Web support

**[featuresFromGeoJsonMainThread](https://pub.dev/documentation/geojson/latest/geojson/featuresFromGeoJsonMainThread.html)**: as the web do not support isolates use this function to parse in the main thread. Parameters:

- `data`: a string with the geojson data, required
- `nameProperty`: the property used for the geoserie name, automaticaly set if null
- `verbose`: print the parsed data if true

## Reactive api

### Parse and listen

Typed streams are available to retrieve the features as soon as they are parsed. This is useful when the data is big.

- `processedFeatures`: the parsed features: all the geometries
- `processedPoints`: the parsed points
- `processedMultipoints`: the parsed multipoints
- `processedLines`: the parsed lines
- `processedMultilines`: the parsed multilines
- `processedPolygons`: the parsed polygons
- `processedMultipolygons`: the parsed multipolygons
- `endSignal`: parsing is finished indicator

Example: add assets on a Flutter map:

```dart
  import 'package:flutter/services.dart' show rootBundle;
  import 'package:geojson/geojson.dart';
  import 'package:flutter_map/flutter_map.dart';

  /// Data for the Flutter map polylines layer
  final lines = <Polyline>[];

  Future<void> parseAndDrawAssetsOnMap() async {
    final geo = GeoJson();
    geo.processedLines.listen((GeoJsonLine line) {
      /// when a line is parsed add it to the map right away
      setState(() => lines.add(Polyline(
          strokeWidth: 2.0, color: Colors.blue, points: line.geoSerie.toLatLng())));
    });
    geo.endSignal.listen((_) => geo.dispose());
    final data = await rootBundle
        .loadString('assets/railroads_of_north_america.geojson');
    await geo.parse(data, verbose: true);
  }
```

### Data properties

After the data is parsed the `GeoJson` instance has properties to access the data:

```dart
List<GeoJsonFeature> features;
List<GeoJsonPoint> points;
List<GeoJsonMultiPoint> multipoints;
List<GeoJsonLine> lines;
List<GeoJsonMultiLine> multilines;
List<GeoJsonPolygon> polygons;
List<GeoJsonMultiPolygon> multipolygons;
```

Example:

```dart
final List<GeoJsonLine> lines = geo.lines;
```

## Search

Search in  a geojson file:

```dart
final geo = GeoJson();
await geo.searchInFile("countries.geojson",
    query: GeoJsonQuery(
        geometryType: GeoJsonFeatureType.multipolygon,
        matchCase: false,
        property: "name",
        value: "Zimbabwe"),
    verbose: true);
List<GeoJsonMultiPolygon> result = geo.multipolygons;
```

A `search` method is also available, taking string data in parameter instead of a file path. The streams are available to retrieve the data as soon as it is found

## Geofencing

Geofence points within a distance of a given point:

   ```dart
   final geo = GeoJson();
   /// `point` is the [GeoJsonPoint] to search from
   /// `points` is the list of [GeoJsonPoint] to search in
   /// `distance` is the distance to search in meters
   await geo.geofenceDistance(
         point: point, points: points, distance: distance);
    List<GeoPoint> foundPoints = geo.points;
   ```

Geofence points in a polygon:

   ```dart
   final geo = GeoJson();
   /// `polygon` is the [GeoJsonPolygon] to check
   /// `points` is the list of [GeoJsonPoint] to search in
   await geo.geofencePolygon(polygon: polygon, points: points);
    List<GeoPoint> foundPoints = geo.points;
   ```

Note: the `processedPoints` stream is available to retrieve geofenced points as soon as they are found

## Maps

To draw geojson data on a map check the [Map controller](https://github.com/synw/map_controller#geojson-data) package

## Supported geojson features

All the data structures use [GeoPoint](https://pub.dev/documentation/geopoint/latest/geopoint/GeoPoint-class.html) and [GeoSerie](https://pub.dev/documentation/geopoint/latest/geopoint/GeoSerie-class.html) from the [GeoPoint](https://github.com/synw/geopoint) package to store the geometry data. Data structures used:

**[GeoJsonFeatureCollection](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonFeatureCollection-class.html)**:

- `String` **name**
- `List<GeoJsonFeature>` **collection**

**[GeoJsonFeature](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonFeature-class.html)**:

- `GeoJsonFeatureType` **type**: [types](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonFeatureType-class.html)

- `Map<String, dynamic>` **properties**: the json properties of the feature
- `dynamic` **geometry**: the geometry data, depends on the feature type, see below

**[GeoJsonPoint](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonPoint-class.html)**:

- `String` **name**
- `GeoPoint` **geoPoint**: the geometry data

**[GeoJsonMultiPoint](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonMultiPoint-class.html)**:

- `String` **name**
- `GeoSerie` **geoSerie**: the geometry data: this will produce a geoSerie of type `GeoSerieType.group`

**[GeoJsonLine](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonLine-class.html)**:

- `String` **name**
- `GeoSerie` **geoSerie**: the geometry data: this will produce a geoSerie of type `GeoSerieType.line`

**[GeoJsonMultiLine](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonMultiLine-class.html)**:

- `String` **name**
- `List<GeoJsonLine>` **lines**

**[GeoJsonPolygon](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonPolygon-class.html)**:

- `String` **name**
- `List<GeoSerie>` **geoSeries**: the geometry data: this will produce a list of geoSerie of type `GeoSerieType.polygon`*

**[GeoJsonMultiPolygon](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonMultiPolygon-class.html)**:

- `String` **name**
- `List<GeoJsonPolygon>` **polygons**

**[GeoJsonGeometryCollection](https://pub.dev/documentation/geojson/latest/geojson/GeoJsonGeometryCollection-class.html)**:

- `String` **name**
- `List<GeoJsonFeature>` geometries

Note: none of the parameters is final for all of these data structures
