import 'dart:async';
import 'dart:io';
import 'geojson.dart';
import 'models.dart';

/// Get a feature collection from a geojson string
Future<GeoJsonFeatureCollection> featuresFromGeoJson(String data,
    {String nameProperty, bool verbose = false}) async {
  final featureCollection = GeoJsonFeatureCollection();
  final geojson = GeoJson();
  await geojson.parse(data, nameProperty: nameProperty, verbose: verbose);
  for (final feature in geojson.features) {
    featureCollection.collection.add(feature);
  }
  geojson.dispose();
  return featureCollection;
}

/// Get a feature collection from a geojson file
Future<GeoJsonFeatureCollection> featuresFromGeoJsonFile(File file,
    {String nameProperty, bool verbose = false}) async {
  final featureCollection = GeoJsonFeatureCollection();
  final geojson = GeoJson();
  await geojson.parseFile(file.path,
      nameProperty: nameProperty, verbose: verbose);
  for (final feature in geojson.features) {
    featureCollection.collection.add(feature);
  }
  geojson.dispose();
  return featureCollection;
}
