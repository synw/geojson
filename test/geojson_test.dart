import "package:test/test.dart";
import "package:geojson/geojson.dart";
import 'data.dart';

void main() {
  test("point", () async {
    final features = await featuresFromGeoJson(geojsonPoint);
    final feature = features.collection[0];
    expect(feature.type, FeatureType.point);
    final point = feature.geometry as Point;
    expect(point.geoPoint.latitude, 0);
    expect(point.geoPoint.longitude, 0);
    expect(point.name, "point");
  });

  test("multipoint", () async {
    final features = await featuresFromGeoJson(geojsonMultiPoint);
    final feature = features.collection[0];
    expect(feature.type, FeatureType.multipoint);
    final multipoint = feature.geometry as MultiPoint;
    expect(multipoint.geoSerie.geoPoints.length, 2);
  });

  test("line", () async {
    final features =
        await featuresFromGeoJson(geojsonLine, nameProperty: "nameprop");
    final feature = features.collection[0];
    expect(feature.type, FeatureType.line);
    final line = feature.geometry as Line;
    expect(line.geoSerie.geoPoints.length, 2);
    expect(line.name, "line");
  });

  test("multiline", () async {
    final features = await featuresFromGeoJson(geojsonMultiLine);
    final feature = features.collection[0];
    expect(feature.type, FeatureType.multiline);
    final multiLine = feature.geometry as MultiLine;
    expect(multiLine.lines.length, 4);
  });

  test("polygon", () async {
    final features = await featuresFromGeoJson(geojsonPolygon);
    final feature = features.collection[0];
    expect(feature.type, FeatureType.polygon);
    final polygon = feature.geometry as Polygon;
    expect(polygon.geoSeries[0].geoPoints.length, 3);
  });

  test("multipolygon", () async {
    final features = await featuresFromGeoJson(geojsonMultiPolygon);
    final feature = features.collection[0];
    expect(feature.type, FeatureType.multipolygon);
    final multipolygon = feature.geometry as MultiPolygon;
    expect(multipolygon.polygons.length, 3);
  });
}
