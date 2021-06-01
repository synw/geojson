import 'dart:async';
import 'dart:io';
import 'geojson.dart';
import 'models.dart';

/// Get a feature collection from a geojson string
Future<GeoJsonFeatureCollection> featuresFromGeoJson(String data,
    {String? nameProperty, bool verbose = false}) async {
  final featureCollection = GeoJsonFeatureCollection();
  final geojson = GeoJson();
  geojson.endSignal.listen((_) => geojson.dispose());
  try {
    await geojson.parse(data, nameProperty: nameProperty, verbose: verbose);
  } catch (e) {
    rethrow;
  }
  geojson.features.forEach((f) => featureCollection.collection.add(f));
  return featureCollection;
}

/// Get a feature collection from a geojson file
Future<GeoJsonFeatureCollection> featuresFromGeoJsonFile(File file,
    {String? nameProperty, bool verbose = false}) async {
  final featureCollection = GeoJsonFeatureCollection();
  final geojson = GeoJson();
  geojson.endSignal.listen((_) => geojson.dispose());
  try {
    await geojson.parseFile(file.path,
        nameProperty: nameProperty, verbose: verbose);
  } catch (e) {
    rethrow;
  }
  geojson.features.forEach((f) => featureCollection.collection.add(f));
  return featureCollection;
}

/// Get a feature collection from a geojson string using a parser
/// in the main thread, without isolates: necessary for the web
Future<GeoJsonFeatureCollection> featuresFromGeoJsonMainThread(String data,
    {String? nameProperty, bool verbose = false}) async {
  final featureCollection = GeoJsonFeatureCollection();
  final geojson = GeoJson();
  geojson.endSignal.listen((_) => geojson.dispose());
  try {
    await geojson.parseInMainThread(data,
        nameProperty: nameProperty, verbose: verbose);
  } catch (e) {
    rethrow;
  }
  geojson.features.forEach((f) {
    if (verbose) {
      print("Feature: ${f.type}");
    }
    featureCollection.collection.add(f);
  });
  return featureCollection;
}
