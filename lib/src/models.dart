import 'package:geopoint/geopoint.dart';

/// Geojson feature types
enum FeatureType {
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
class FeatureCollection {
  /// Default constructor
  FeatureCollection([this.collection]) {
    collection ??= <Feature>[];
  }

  /// A features collection
  List<Feature> collection;

  /// The collection name
  String name;
}

/// A geojson feature
class Feature<T> {
  /// The type of the feature
  FeatureType type;

  /// The feature properties
  Map<String, dynamic> properties;

  /// The feature geo data
  T geometry;

  /// The number of [GeoPoint] contained in the feature geometry
  int get length => _length();

  int _length() {
    int total = 0;
    switch (type) {
      case FeatureType.point:
        total = 1;
        break;
      case FeatureType.multipoint:
        final g = geometry as MultiPoint;
        total = g.geoSerie.geoPoints.length;
        break;
      case FeatureType.line:
        final g = geometry as Line;
        total = g.geoSerie.geoPoints.length;
        break;
      case FeatureType.multiline:
        final g = geometry as MultiLine;
        for (final line in g.lines) {
          total = total + line.geoSerie.geoPoints.length;
        }
        break;
      case FeatureType.polygon:
        final g = geometry as Polygon;
        for (final geoSerie in g.geoSeries) {
          total = total + geoSerie.geoPoints.length;
        }
        break;
      case FeatureType.multipolygon:
        final g = geometry as MultiPolygon;
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
class Point {
  /// Default constructor
  Point({this.geoPoint, this.name});

  /// The geometry data
  GeoPoint geoPoint;

  /// The name of the point
  String name;
}

/// Multiple points
class MultiPoint {
  /// Default constructor
  MultiPoint({this.geoSerie, this.name});

  /// The geometry data
  GeoSerie geoSerie;

  /// The name of the point
  String name;
}

/// A line
class Line {
  /// Default constructor
  Line({this.geoSerie, this.name});

  /// The geometry data
  GeoSerie geoSerie;

  /// The name of the line
  String name;
}

/// A multiline
class MultiLine {
  /// Default constructor
  MultiLine({this.lines, this.name}) {
    lines ??= <Line>[];
  }

  /// The geometry data
  List<Line> lines;

  /// The name of the line
  String name;
}

/// A polygon
class Polygon {
  /// Default constructor
  Polygon({this.geoSeries, this.name}) {
    geoSeries ??= <GeoSerie>[];
  }

  /// The geometry data
  List<GeoSerie> geoSeries;

  /// The name of the polygon
  String name;
}

/// A multipolygon
class MultiPolygon {
  /// Default constructor
  MultiPolygon({this.polygons, this.name}) {
    polygons ??= <Polygon>[];
  }

  /// The geometry data
  List<Polygon> polygons;

  /// The name of the multipolygon
  String name;
}
