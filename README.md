# Geojson

[![pub package](https://img.shields.io/pub/v/geojson.svg)](https://pub.dartlang.org/packages/geojson) [![Build Status](https://travis-ci.org/synw/geojson.svg?branch=master)](https://travis-ci.org/synw/geojson) [![Coverage Status](https://coveralls.io/repos/github/synw/geojson/badge.svg?branch=master)](https://coveralls.io/github/synw/geojson?branch=master)

Utilities to work with geojson data in Dart. Features:

- **Parser**: simple functions are available to parse geojson
- **Reactive api**: streams are available to retrieve the geojson features as soon as they are parsed

Note: the data is parsed in an isolate to avoid slowing down the main thread

## Simple functions

`featuresFromGeoJson`: get a `FeaturesCollection` from geojson string data. Parameters:

- `data`: a string with the geojson data, required
- `nameProperty`: the property used for the geoserie name, automaticaly set if null
- `verbose`: print the parsed data if true

`featuresFromGeoJsonFile`: get a `FeaturesCollection` from a geojson file. Parameters:

- `file`: the file to load, required
- `nameProperty`: the property used for the geoserie name, automaticaly set if null
- `verbose`: print the parsed data if true

## Reactive api

Typed streams are available to retrieve the features as soon as they are parsed. Example: add assets on a Flutter map:

```dart
  import 'dart:math' as math;
  import 'package:pedantic/pedantic.dart';
  import 'package:flutter/services.dart' show rootBundle;
  import 'package:geojson/geojson.dart';
  import 'package:flutter_map/flutter_map.dart' as map;

  /// Data for the Flutter map polylines layer
  final lines = <map.Polyline>[];

  Future<void> processData() async {
    final data = await rootBundle
        .loadString('assets/railroads_of_north_america.geojson');
    final geojson = GeoJson();
    geojson.processedLines.listen((Line line) {
      final color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(0.3);
      setState(() => lines.add(map.Polyline(
          strokeWidth: 2.0, color: color, points: line.geoSerie.toLatLng())));
    });
    geojson.endSignal.listen((_) => geojson.dispose());
    unawaited(geojson.parse(data, verbose: true));
  }
```

Check the examples for more details

### Available streams:

- `processedFeatures`: the parsed features: all the geometries
- `processedPoints`: the parsed points
- `processedMultipoints`: the parsed multipoints
- `processedLines`: the parsed lines
- `processedMultilines`: the parsed multilines
- `processedPolygons`: the parsed polygons
- `processedMultipolygons`: the parsed multipolygons
- `endSignal`: parsing is finished indicator

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
