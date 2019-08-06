import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geopoint/geopoint.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson/geojson.dart';
import 'package:flutter_map/flutter_map.dart' as map;

class DataProcessor {
  final countries = <String, map.Polygon>{};

  Future<void> run() async {
    // The data is from https://datahub.io/core/geo-countries
    final data = await rootBundle.loadString('assets/countries.geojson');
    final nameProperty = "ADMIN";
    final features = await featuresFromGeoJson(data,
        nameProperty: nameProperty, verbose: true);
    for (final feature in features.collection) {
      final color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(0.3);
      final geom = feature.geometry as MultiPolygon;
      for (final polygon in geom.polygons) {
        final geoSerie = GeoSerie(
            type: GeoSerieType.polygon,
            name: polygon.geoSeries[0].name,
            geoPoints: <GeoPoint>[]);
        for (final serie in polygon.geoSeries) {
          geoSerie.geoPoints.addAll(serie.geoPoints);
        }
        countries[geoSerie.name] = map.Polygon(
            points: geoSerie.toLatLng(ignoreErrors: true), color: color);
      }
    }
  }
}
