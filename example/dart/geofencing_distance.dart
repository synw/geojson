import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';

void main(List<String> args) async {
  int km = 200;
  if (args.isNotEmpty) {
    km = int.parse(args[0]);
  }
  final distance = km * 1000;
  final geo = GeoJson();
  print("Loading airports");
  await geo.parseFile("../flutter_map/assets/airports.geojson",
      disableStream: true);
  final airports = geo.points;
  print("Loaded ${airports.length} airports");
  geo.processedPoints.listen((GeoJsonPoint point) {
    print("  - ${point.name}");
  });
  final center = GeoJsonPoint(
      geoPoint: GeoPoint(latitude: 48.853831, longitude: 2.348722));
  print("Airports within $km kilometers from Paris:");
  await geo.geofenceDistance(
      point: center, points: airports, distance: distance);
}
