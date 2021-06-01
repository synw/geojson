import 'dart:convert';

import 'package:geopoint/geopoint.dart';

/// Geojson feature types
enum GeoJsonFeatureType {
  /// A point
  point,

  /// Multiple points
  multipoint,

  /// A line
  line,

  /// Multiple lines
  multiline,

  /// A polygon
  polygon,

  /// A multiPolygon
  multipolygon,

  /// A geometry collection
  geometryCollection,
}

/// A list of features
class GeoJsonFeatureCollection {
  /// Default constructor
  GeoJsonFeatureCollection({List<GeoJsonFeature<dynamic>>? collection})
      : this.collection = collection ?? <GeoJsonFeature<dynamic>>[];

  /// A features collection
  List<GeoJsonFeature<dynamic>> collection;

  /// The collection name
  String? name;

  /// Serialize to a geojson features collection
  String serialize() {
    final buffer = StringBuffer()
      ..write('{"type": "FeatureCollection", ' +
          (name == null ? '' : '"name": "$name", '))
      ..write('"features": [');
    for (final feat in collection) {
      buffer.write(feat.serialize());
      if (feat != collection.last) {
        buffer.write(',');
      }
    }
    buffer.write("]}");
    return buffer.toString();
  }
}

/// A geojson feature
class GeoJsonFeature<T> {
  /// The type of the feature
  late GeoJsonFeatureType type;

  /// The feature properties
  Map<String, dynamic>? properties;

  /// The feature geo data
  T? geometry;

  /// The number of [GeoPoint] contained in this feature geometry
  int get length => _length();

  /// Serialize to a geojson feature
  String? serialize() {
    //assert(type != null, "The feature type can not be null for serialization");
    String? featStr;
    switch (type) {
      case GeoJsonFeatureType.point:
        final geom = geometry as GeoJsonPoint?;
        featStr = geom?.serializeFeature(properties);
        break;
      case GeoJsonFeatureType.multipoint:
        final geom = geometry as GeoJsonMultiPoint?;
        featStr = geom?.serializeFeature(properties);
        break;
      case GeoJsonFeatureType.line:
        final geom = geometry as GeoJsonLine?;
        featStr = geom?.serializeFeature(properties);
        break;
      case GeoJsonFeatureType.multiline:
        final geom = geometry as GeoJsonMultiLine?;
        featStr = geom?.serializeFeature(properties);
        break;
      case GeoJsonFeatureType.polygon:
        final geom = geometry as GeoJsonPolygon?;
        featStr = geom?.serializeFeature(properties);
        break;
      case GeoJsonFeatureType.multipolygon:
        final geom = geometry as GeoJsonMultiPolygon?;
        featStr = geom?.serializeFeature();
        break;
      case GeoJsonFeatureType.geometryCollection:
        throw UnimplementedError("Geometry collection not implemented");
      // ignore: no_default_cases
      default:
        throw UnimplementedError("Geometry for '$type' not implemented");
    }
    return featStr;
  }

  int _length() {
    var total = 0;
    switch (type) {
      case GeoJsonFeatureType.point:
        total = 1;
        break;
      case GeoJsonFeatureType.multipoint:
        total =
            (geometry as GeoJsonMultiPoint?)?.geoSerie?.geoPoints.length ?? 0;
        break;
      case GeoJsonFeatureType.line:
        total = (geometry as GeoJsonLine?)?.geoSerie?.geoPoints.length ?? 0;
        break;
      case GeoJsonFeatureType.multiline:
        final g = geometry as GeoJsonMultiLine?;
        if (g != null) {
          for (final line in g.lines) {
            total = total + (line.geoSerie?.geoPoints.length ?? 0);
          }
        }
        break;
      case GeoJsonFeatureType.polygon:
        final g = geometry as GeoJsonPolygon?;
        if (g != null) {
          for (final geoSerie in g.geoSeries) {
            total = total + geoSerie.geoPoints.length;
          }
        }
        break;
      case GeoJsonFeatureType.multipolygon:
        final g = geometry as GeoJsonMultiPolygon?;
        if (g != null) {
          for (final polygon in g.polygons) {
            for (final geoSerie in polygon.geoSeries) {
              total = total + geoSerie.geoPoints.length;
            }
          }
        }
        break;
      case GeoJsonFeatureType.geometryCollection:
        total =
            ((geometry as GeoJsonGeometryCollection?)?.geometries?.length) ?? 0;
    }
    return total;
  }
}

/// A geometry collection
class GeoJsonGeometryCollection {
  /// Default constructor
  GeoJsonGeometryCollection(
      {List<GeoJsonFeature<dynamic>?>? geometries, this.name})
      : geometries = geometries ?? <GeoJsonFeature<dynamic>>[];

  /// The geometries
  List<GeoJsonFeature<dynamic>?>? geometries;

  /// The name of the collection
  String? name;

  /// Add a geometry to the collection
  void add(GeoJsonFeature<dynamic> geom) => geometries?.add(geom);
}

/// A point
class GeoJsonPoint {
  /// Default constructor
  GeoJsonPoint({required this.geoPoint, this.name});

  /// The geometry data
  GeoPoint geoPoint;

  /// The name of the point
  String? name;

  /// Serialize to a geojson feature string
  String serializeFeature(Map<String, dynamic>? properties) {
    final p = properties ?? <String, dynamic>{};
    return '{"type":"Feature","properties":${jsonEncode(p)},'
            '"geometry":{"type":"Point",'
            '"coordinates":' +
        geoPoint.toGeoJsonCoordinatesString() +
        '}}';
  }
}

/// Multiple points
class GeoJsonMultiPoint {
  /// Default constructor
  GeoJsonMultiPoint({this.geoSerie, this.name});

  /// The geometry data
  GeoSerie? geoSerie;

  /// The name of the point
  String? name;

  /// Serialize to a geojson feature string
  String? serializeFeature(Map<String, dynamic>? properties) =>
      geoSerie?.toGeoJsonFeatureString(properties);
}

/// A line
class GeoJsonLine {
  /// Default constructor
  GeoJsonLine({this.geoSerie, this.name});

  /// The geometry data
  GeoSerie? geoSerie;

  /// The name of the line
  String? name;

  /// Serialize to a geojson feature string
  String? serializeFeature(Map<String, dynamic>? properties) =>
      geoSerie?.toGeoJsonFeatureString(properties);
}

/// A multiline
class GeoJsonMultiLine {
  /// Default constructor
  GeoJsonMultiLine({List<GeoJsonLine>? lines, this.name})
      : this.lines = lines ?? <GeoJsonLine>[];

  /// The geometry data
  List<GeoJsonLine> lines;

  /// The name of the line
  String? name;

  /// Serialize to a geojson feature string
  String serializeFeature(Map<String, dynamic>? properties) {
    final geoSeries = <GeoSerie?>[];
    for (final line in lines) {
      geoSeries.add(line.geoSerie);
    }
    return _buildGeoJsonFeature(
        geoSeries, "Line", properties ?? <String, dynamic>{"name": name});
  }
}

/// A polygon
class GeoJsonPolygon {
  /// Default constructor
  GeoJsonPolygon({List<GeoSerie>? geoSeries, this.name})
      : this.geoSeries = geoSeries ?? <GeoSerie>[];

  /// The geometry data
  List<GeoSerie> geoSeries;

  /// The name of the polygon
  String? name;

  /// Serialize to a geojson feature string
  String serializeFeature(Map<String, dynamic>? properties) {
    return _buildGeoJsonFeature(
        geoSeries, "Polygon", properties ?? <String, dynamic>{"name": name});
  }
}

/// A multipolygon
class GeoJsonMultiPolygon {
  /// Default constructor
  GeoJsonMultiPolygon({List<GeoJsonPolygon>? polygons, this.name})
      : this.polygons = polygons ?? <GeoJsonPolygon>[];

  /// The geometry data
  List<GeoJsonPolygon> polygons;

  /// The name of the multipolygon
  String? name;

  /// Serialize to a geojson feature string
  String serializeFeature() => _buildMultiGeoJsonFeature(polygons, name);
}

/// The type of search to process
enum GeoSearchType {
  /// Find the exact values
  exact,

  /// Find the values that starts with
  startsWith,

  /// Find the values contained in string
  contains
}

/// A geojson query for search
class GeoJsonQuery {
  /// Provide a [geometryType] and/or a [property] and [value]
  GeoJsonQuery(
      {this.property,
      this.value,
      this.geometryType,
      this.matchCase = true,
      this.searchType = GeoSearchType.exact}) {
    if (geometryType == null) {
      if (property == null || value == null) {
        throw ArgumentError.notNull(
            "Property and value must not be null if no geometry "
            "type is provided");
      }
    }
  }

  /// The property to search for
  final String? property;

  /// The value of the property to search for
  final dynamic value;

  /// The type of geometry to search for
  final GeoJsonFeatureType? geometryType;

  /// The type of search to process (for strings)
  final GeoSearchType searchType;

  /// Match the case of string or not
  final bool matchCase;
}

String _buildGeoJsonFeature(
    List<GeoSerie?> geoSeries, String type, Map<String, dynamic> properties) {
  final coordsList = <String>[];
  for (final geoSerie in geoSeries) {
    if (geoSerie != null) {
      coordsList.add(geoSerie.toGeoJsonCoordinatesString());
    }
  }
  final coords = '[' + coordsList.join(",") + ']';
  return '{"type":"Feature","properties":${jsonEncode(properties)},'
          '"geometry":{"type":"$type",'
          '"coordinates":' +
      coords +
      '}}';
}

String _buildMultiGeoJsonFeature(List<GeoJsonPolygon> polygons, String? name) {
  final polyList = <String>[];
  for (final polygon in polygons) {
    final coordsList = <String>[];
    for (final geoSerie in polygon.geoSeries) {
      coordsList.add(geoSerie.toGeoJsonCoordinatesString());
    }
    final pcoords = '[' + coordsList.join(",") + ']';
    polyList.add(pcoords);
  }
  final coords = polyList.join(",");
  return '[{"type":"Feature","properties":{"name":"$name"}, '
          '"geometry":{"type":"MultiPolygon",'
          '"coordinates":' +
      coords +
      '}}]';
}
