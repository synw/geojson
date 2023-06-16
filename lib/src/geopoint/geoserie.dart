import 'dart:convert';

import 'package:latlong2/latlong.dart';

import 'geopoint.dart';

/// The type of the geoserie: group of points, line or polygon
enum GeoSerieType {
  /// A group of geo points
  group,

  /// A group of geo points forming a line
  line,

  /// A group of geo points forming a polygon
  polygon,
}

/// [GeoSerieType] Extension
extension GeoSerieTypeExtension on GeoSerieType {
  /// String value of [GeoSerieType] Enum.
  String stringValue() {
    switch (this) {
      case GeoSerieType.group:
        return "group";
      case GeoSerieType.line:
        return "line";
      case GeoSerieType.polygon:
        return "polygon";
    }
  }

  /// feature String value of [GeoSerieType] Enum.
  String featureString() {
    switch (this) {
      case GeoSerieType.group:
        return "MultiPoint";
      case GeoSerieType.line:
        return "LineString";
      case GeoSerieType.polygon:
        return "Polygon";
    }
  }
}

/// static method to convert string to [GeoSerieType].
GeoSerieType _typeFromString(String? typeStr) {
  switch (typeStr?.toLowerCase()) {
    case "group":
      return GeoSerieType.group;
    case "line":
      return GeoSerieType.line;
    case "polygon":
      return GeoSerieType.polygon;
    case "multipoint":
      return GeoSerieType.group;
    case "linestring":
      return GeoSerieType.line;
  }
  throw Exception("Invalid Type");
}

/// A class to hold information about a serie of [GeoPoint]
class GeoSerie {
  /// Default constructor: requires a [name] and a [type]
  GeoSerie(
      {required this.name,
      required this.type,
      this.id,
      this.surface,
      this.boundary,
      this.centroid,
      List<GeoPoint>? geoPoints})
      : this.geoPoints = geoPoints ?? <GeoPoint>[];

  /// Name if the geoserie
  String name;

  /// Id of the geoserie
  int? id;

  /// Type of the geoserie
  GeoSerieType type;

  /// The list of [GeoPoint] in the serie
  List<GeoPoint> geoPoints;

  /// The surface of a geometry
  num? surface;

  /// Boundaries of a geometry
  GeoSerie? boundary;

  /// The centroid of a geometry
  GeoPoint? centroid;

  /// The type of the serie as a string
  String get typeStr => type.stringValue();

  /// Make a [GeoSerie] from json data
  GeoSerie.fromJson(Map<String, dynamic> json)
      : name = "${json["name"]}",
        id = int.parse("${json["id"]}"),
        surface = double.tryParse("${json["surface"]}"),
        type = _typeFromString("${json["type"]}"),
        this.geoPoints = <GeoPoint>[];

  /// Make a [GeoSerie] from name and serie type
  GeoSerie.fromNameAndType(
      {required this.name, required String typeStr, this.id})
      : type = _typeFromString(typeStr),
        this.geoPoints = <GeoPoint>[];

  /// [name] the name of the [GeoSerie]
  /// [typeStr] the type of the serie: group, line or polygon
  /// [id] the id of the serie

  /// Get a json map from this [GeoSerie]
  Map<String, dynamic> toMap({bool withId = true}) {
    /// [withId] include the id in the result
    final json = <String, dynamic>{
      "name": name,
      "type": typeStr,
      "surface": surface
    };
    if (withId) {
      json["id"] = id;
    }
    return json;
  }

  /// Get a list of [LatLng] from this [GeoSerie]
  List<LatLng> toLatLng({bool ignoreErrors = false}) {
    final points = <LatLng>[];
    for (final geoPoint in geoPoints) {
      try {
        points.add(geoPoint.point);
      } catch (_) {
        if (!ignoreErrors) {
          rethrow;
        }
      }
    }
    return points;
  }

  /// Convert to a geojson coordinates string
  String toGeoJsonCoordinatesString() {
    final coords = <String>[];

    for (final geoPoint in geoPoints) {
      coords.add(geoPoint.toGeoJsonCoordinatesString());
    }
    return "[" + coords.join(",") + "]";
  }

  /// Convert to a geojson feature string
  String toGeoJsonFeatureString(Map<String, dynamic>? properties) =>
      _buildGeoJsonFeature(type, properties ?? <String, dynamic>{"name": name});

  String _buildGeoJsonFeature(
      GeoSerieType type, Map<String, dynamic> properties) {
    var extra1 = "";
    var extra2 = "";
    if (type == GeoSerieType.polygon) {
      extra1 = "[";
      extra2 = "]";
    }
    return '{"type":"Feature","properties":${jsonEncode(properties)},'
            '"geometry":{"type":"${type.featureString()}",'
            '"coordinates":' +
        extra1 +
        toGeoJsonCoordinatesString() +
        extra2 +
        '}}';
  }
}
