import 'package:geopoint/geopoint.dart';

import 'models.dart';

/// Get a collection inside another collection
GeoJsonGeometryCollection getGeometryCollection(
    {List<GeoJsonFeature<dynamic>?>? geometries,
    GeoJsonFeature<dynamic>? feature,
    String? nameProperty}) {
  final name = _getName(feature: feature, nameProperty: nameProperty);
  final collection =
      GeoJsonGeometryCollection(geometries: geometries, name: name);
  return collection;
}

/// Get a point from coordinates and feature
GeoJsonPoint getPoint(
    {List<dynamic>? coordinates,
    GeoJsonFeature<dynamic>? feature,
    String? nameProperty}) {
  final name = _getName(feature: feature, nameProperty: nameProperty);
  final geoPoint = _getGeoPoints(<dynamic>[coordinates])[0]..name = name;
  return GeoJsonPoint(geoPoint: geoPoint, name: name);
}

/// Get multi points from coordinates and feature
GeoJsonMultiPoint getMultiPoint(
    {required List<dynamic> coordinates,
    GeoJsonFeature<dynamic>? feature,
    String? nameProperty}) {
  final multiPoint = GeoJsonMultiPoint();
  final name = _getName(feature: feature, nameProperty: nameProperty);
  multiPoint.name = name;
  final geoSerie = GeoSerie(
      name: name,
      type: GeoSerieType.group,
      geoPoints: _getGeoPoints(coordinates));
  multiPoint.geoSerie = geoSerie;
  return multiPoint;
}

/// Get a line from coordinates and feature
GeoJsonLine getLine(
    {required List<dynamic> coordinates,
    GeoJsonFeature<dynamic>? feature,
    String? nameProperty}) {
  final line = GeoJsonLine();
  final name = _getName(feature: feature, nameProperty: nameProperty);
  line.name = name;
  final geoSerie = GeoSerie(
      name: name,
      type: GeoSerieType.line,
      geoPoints: _getGeoPoints(coordinates));
  line.geoSerie = geoSerie;
  return line;
}

/// Get a multi line from coordinates and feature
GeoJsonMultiLine getMultiLine(
    {required List<dynamic> coordinates,
    GeoJsonFeature<dynamic>? feature,
    String? nameProperty}) {
  final name = _getName(feature: feature, nameProperty: nameProperty);
  final multiLine = GeoJsonMultiLine(name: name);
  var i = 1;
  for (final coords in coordinates) {
    final line = GeoJsonLine()
      ..name = _getName(feature: feature, nameProperty: nameProperty, index: i);
    final geoSerie = GeoSerie(
        name: name,
        type: GeoSerieType.line,
        geoPoints: _getGeoPoints(coords as List<dynamic>));
    line.geoSerie = geoSerie;
    multiLine.lines.add(line);
    ++i;
  }
  return multiLine;
}

/// Get a polygon from coordinates and feature
GeoJsonPolygon getPolygon(
    {required List<dynamic> coordinates,
    GeoJsonFeature<dynamic>? feature,
    String? nameProperty}) {
  final polygon = GeoJsonPolygon();
  final name = _getName(feature: feature, nameProperty: nameProperty);
  polygon.name = name;
  for (final coords in coordinates) {
    final geoSerie = GeoSerie(
        name: _getName(feature: feature, nameProperty: nameProperty),
        type: GeoSerieType.polygon)
      ..geoPoints = _getGeoPoints(coords as List<dynamic>);
    polygon.geoSeries.add(geoSerie);
  }
  return polygon;
}

/// Get a multiPolygon from coordinates and feature
GeoJsonMultiPolygon getMultiPolygon(
    {required List<dynamic> coordinates,
    GeoJsonFeature<dynamic>? feature,
    String? nameProperty}) {
  final multiPolygon = GeoJsonMultiPolygon();
  var i = 1;
  multiPolygon.name = _getName(feature: feature, nameProperty: nameProperty);
  for (final coordsL2 in coordinates) {
    final polygon = GeoJsonPolygon();
    final name =
        _getName(feature: feature, nameProperty: nameProperty, index: i);
    polygon.name = name;
    for (final coords in coordsL2) {
      final geoSerie = GeoSerie(
          name: _getName(feature: feature, nameProperty: nameProperty),
          type: GeoSerieType.polygon)
        ..geoPoints = _getGeoPoints(coords as List<dynamic>);
      polygon.geoSeries.add(geoSerie);
    }
    multiPolygon.polygons.add(polygon);
    ++i;
  }
  return multiPolygon;
}

String _getName(
    {GeoJsonFeature<dynamic>? feature, String? nameProperty, int? index}) {
  String? name;
  if (nameProperty != null) {
    name = feature?.properties?[nameProperty]?.toString();
  } else {
    if (feature?.properties?.containsKey("name") == true) {
      name = feature?.properties?["name"]?.toString();
    }
  }
  if (name == null || name == "null") {
    name = "serie";
    if (index != null) {
      name = "serie_$index";
    }
  }
  return name;
}

List<GeoPoint> _getGeoPoints(List<dynamic> coordsList) {
  final geoPoints = <GeoPoint>[];
  for (final coordinates in coordsList) {
    if (!(coordinates is List)) continue; // skip
    final geoPoint = GeoPoint(
        latitude: double.parse(coordinates[1].toString()),
        longitude: double.parse(coordinates[0].toString()),
        altitude: (coordinates.length >= 3) == true
            ? double.parse(coordinates[2].toString())
            : null);
    geoPoints.add(geoPoint);
  }
  return geoPoints;
}
