import 'dart:io';

import "package:geojson/geojson.dart";
import 'package:geopoint/geopoint.dart';
import "package:test/test.dart";

import 'data.dart';

void main() {
  test("nested geometrycollection", () async {
    final features = await featuresFromGeoJson(geojsonNestedGeometryCollection);
    expect(features.collection.length, 1);
    final feature = features.collection[0];
    expect(feature.type, GeoJsonFeatureType.geometryCollection);
    final collection = feature.geometry as GeoJsonGeometryCollection;
    expect(collection.geometries.length, 2);
    expect(
        collection.geometries[0].type, GeoJsonFeatureType.geometryCollection);
    final innerCollection =
        collection.geometries[0].geometry as GeoJsonGeometryCollection;
    expect(innerCollection.geometries.length, 2);
    expect(
        innerCollection.geometries
            .every((element) => element.type == GeoJsonFeatureType.point),
        true);

    expect(collection.geometries[1].type, GeoJsonFeatureType.point);
    final point = collection.geometries[1].geometry as GeoJsonPoint;
    expect(point.geoPoint.latitude, 0);
    expect(point.geoPoint.longitude, 0);
  });

  test("point", () async {
    final features = await featuresFromGeoJson(geojsonPoint);
    expect(features.collection.length, 1);
    final feature = features.collection[0];
    expect(feature.type, GeoJsonFeatureType.point);
    final point = feature.geometry as GeoJsonPoint;
    expect(point.geoPoint.latitude, 0);
    expect(point.geoPoint.longitude, 0);
    expect(point.name, "point");
  });

  test("multipoint", () async {
    final features = await featuresFromGeoJson(geojsonMultiPoint);
    final feature = features.collection[0];
    expect(feature.type, GeoJsonFeatureType.multipoint);
    final multipoint = feature.geometry as GeoJsonMultiPoint;
    expect(multipoint.geoSerie.geoPoints.length, 2);
  });

  test("line", () async {
    final features =
        await featuresFromGeoJson(geojsonLine, nameProperty: "nameprop");
    final feature = features.collection[0];
    expect(feature.type, GeoJsonFeatureType.line);
    final line = feature.geometry as GeoJsonLine;
    expect(line.geoSerie.geoPoints.length, 2);
    expect(line.name, "line");
  });

  test("multiline", () async {
    final features = await featuresFromGeoJson(geojsonMultiLine);
    final feature = features.collection[0];
    expect(feature.type, GeoJsonFeatureType.multiline);
    final multiLine = feature.geometry as GeoJsonMultiLine;
    expect(multiLine.lines.length, 4);
  });

  test("polygon", () async {
    final features = await featuresFromGeoJson(geojsonPolygon);
    final feature = features.collection[0];
    expect(feature.type, GeoJsonFeatureType.polygon);
    final polygon = feature.geometry as GeoJsonPolygon;
    expect(polygon.geoSeries[0].geoPoints.length, 3);
  });

  test("multipolygon", () async {
    final features = await featuresFromGeoJson(geojsonMultiPolygon);
    final feature = features.collection[0];
    expect(feature.type, GeoJsonFeatureType.multipolygon);
    final multipolygon = feature.geometry as GeoJsonMultiPolygon;
    expect(multipolygon.polygons.length, 3);
  });

  test("wrongfile", () async {
    await featuresFromGeoJsonFile(File("test/wrong.geojson"))
        .catchError((dynamic e) {
      expect(e.runtimeType.toString() == "FileSystemException", true);
      expect(e.message, "The file test/wrong.geojson does not exist");
    });
  });

  test("unreadablefile", () async {
    await featuresFromGeoJsonFile(File("test/data.bin"))
        .catchError((dynamic e) {
      expect(e.runtimeType.toString() == "FileSystemException", true);
      expect(
          e.message,
          "Can not read file FileSystemException: "
          "Failed to decode data using encoding 'utf-8', path = 'test/data.bin'");
    });
  });

  test("file", () async {
    final features = await featuresFromGeoJsonFile(File("test/data.geojson"));
    expect(features.collection.length, 1);
    final feature = features.collection[0];
    expect(feature.type, GeoJsonFeatureType.point);
    final point = feature.geometry as GeoJsonPoint;
    expect(point.geoPoint.latitude, 0);
    expect(point.geoPoint.longitude, 0);
    expect(point.name, "point");
  });
/*
  test("unknown_feature", () async {
    try {
      await featuresFromGeoJson(geojsonUnsupported);
    } on FeatureNotSupported catch (e) {
      expect(e.message, "The feature Unknown is not supported");
    }
  });*/

  test("point properties", () async {
    final gfc = GeoJsonFeatureCollection()..name="mapmatch";
    final lprops = Map<String, dynamic>();
    lprops["point_color"] = "#000";
    lprops["point_size"] = "7";
    final lp = GeoJsonFeature<GeoJsonPoint>()
      ..type=GeoJsonFeatureType.point
      ..properties=lprops
      ..geometry=GeoJsonPoint(
        geoPoint: GeoPoint(latitude: 37.111, longitude: 126.000), name: "a");
    gfc.collection.add(lp);
    final s = gfc.serialize();
    expect(s.contains("\"point_size\":\"7\""), true);
    expect(s.contains("\"point_color\":\"#000\""), true);
  });
}
