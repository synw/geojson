import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson/geojson.dart';
import 'package:flutter_map/flutter_map.dart' as map;

class DataProcessor {
  final lines = <map.Polyline>[];
  int numPoints = 0;

  Future<void> run() async {
    // data is from http://www.naturalearthdata.com
    final data = await rootBundle
        .loadString('assets/railroads_of_north_america.geojson');
    final features = await featuresFromGeoJson(data, verbose: true);
    for (final feature in features.collection) {
      final color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(0.3);
      final geom = feature.geometry as Line;
      lines.add(map.Polyline(
          strokeWidth: 2.0, color: color, points: geom.geoSerie.toLatLng()));
      numPoints = numPoints + feature.length;
    }
  }
}
