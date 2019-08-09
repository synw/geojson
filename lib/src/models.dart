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

  /// A multipolygon
  multipolygon
}

/// A list of features
class GeoJsonFeatureCollection {
  /// Default constructor
  GeoJsonFeatureCollection([this.collection]) {
    collection ??= <GeoJsonFeature>[];
  }

  /// A features collection
  List<GeoJsonFeature> collection;

  /// The collection name
  String name;
}

/// A geojson feature
class GeoJsonFeature<T> {
  /// The type of the feature
  GeoJsonFeatureType type;

  /// The feature properties
  Map<String, dynamic> properties;

  /// The feature geo data
  T geometry;

  /// The number of [GeoPoint] contained in the feature geometry
  int get length => _length();

  int _length() {
    int total = 0;
    switch (type) {
      case GeoJsonFeatureType.point:
        total = 1;
        break;
      case GeoJsonFeatureType.multipoint:
        GeoJsonMultiPoint g = geometry as GeoJsonMultiPoint;
        total = g.geoSerie.geoPoints.length;
        break;
      case GeoJsonFeatureType.line:
        final g = geometry as GeoJsonLine;
        total = g.geoSerie.geoPoints.length;
        break;
      case GeoJsonFeatureType.multiline:
        final g = geometry as GeoJsonMultiLine;
        for (final line in g.lines) {
          total = total + line.geoSerie.geoPoints.length;
        }
        break;
      case GeoJsonFeatureType.polygon:
        final g = geometry as GeoJsonPolygon;
        for (final geoSerie in g.geoSeries) {
          total = total + geoSerie.geoPoints.length;
        }
        break;
      case GeoJsonFeatureType.multipolygon:
        final g = geometry as GeoJsonMultiPolygon;
        for (final polygon in g.polygons) {
          for (final geoSerie in polygon.geoSeries) {
            total = total + geoSerie.geoPoints.length;
          }
        }
        break;
    }
    return total;
  }
}

/// A point
class GeoJsonPoint {
  /// Default constructor
  GeoJsonPoint({this.geoPoint, this.name});

  /// The geometry data
  GeoPoint geoPoint;

  /// The name of the point
  String name;
}

/// Multiple points
class GeoJsonMultiPoint {
  /// Default constructor
  GeoJsonMultiPoint({this.geoSerie, this.name});

  /// The geometry data
  GeoSerie geoSerie;

  /// The name of the point
  String name;
}

/// A line
class GeoJsonLine {
  /// Default constructor
  GeoJsonLine({this.geoSerie, this.name});

  /// The geometry data
  GeoSerie geoSerie;

  /// The name of the line
  String name;
}

/// A multiline
class GeoJsonMultiLine {
  /// Default constructor
  GeoJsonMultiLine({this.lines, this.name}) {
    lines ??= <GeoJsonLine>[];
  }

  /// The geometry data
  List<GeoJsonLine> lines;

  /// The name of the line
  String name;
}

/// A polygon
class GeoJsonPolygon {
  /// Default constructor
  GeoJsonPolygon({this.geoSeries, this.name}) {
    geoSeries ??= <GeoSerie>[];
  }

  /// The geometry data
  List<GeoSerie> geoSeries;

  /// The name of the polygon
  String name;
}

/// A multipolygon
class GeoJsonMultiPolygon {
  /// Default constructor
  GeoJsonMultiPolygon({this.polygons, this.name}) {
    polygons ??= <GeoJsonPolygon>[];
  }

  /// The geometry data
  List<GeoJsonPolygon> polygons;

  /// The name of the multipolygon
  String name;
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
      this.searchType = GeoSearchType.exact}) {
    if (geometryType == null) {
      if (property == null || value == null) {
        throw (ArgumentError.notNull(
            "Property and value must not be null if no geometry " +
                "type is provided"));
      }
    }
  }

  /// The property to search for
  final String property;

  /// The value of the property to search for
  final dynamic value;

  /// The type of geometry to search for
  final GeoJsonFeatureType geometryType;

  /// The type of search to process (for strings)
  final GeoSearchType searchType;
}
