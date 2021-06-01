import 'package:geojson/geojson.dart';

Future<void> main(List<String> args) async {
  String countryName;
  if (args.isEmpty) {
    countryName = "Germany";
  } else {
    countryName = args[0];
  }
  final geo = GeoJson();

  print("Searching for country $countryName");
  await geo.searchInFile("../flutter_map/assets/countries.geojson",
      query: GeoJsonQuery(
          geometryType: GeoJsonFeatureType.multipolygon,
          matchCase: false,
          property: "ADMIN",
          value: countryName),
      nameProperty: "ADMIN",
      verbose: true);
  if (geo.multiPolygons.isEmpty) {
    print("Country $countryName not found");
    return;
  }
  final country = geo.multiPolygons;
  print("Loading airports");
  await geo.parseFile("../flutter_map/assets/airports.geojson",
      disableStream: true);
  final airports = geo.points;
  print("Loaded ${airports.length} airports");
  print("Geofencing airports in $countryName");
  print("Airports in $countryName:");
  geo.processedPoints.listen((GeoJsonPoint point) {
    print("  - ${point.name}");
  });
  for (final countryPolygons in country) {
    for (final polygon in countryPolygons.polygons) {
      await geo.geofencePolygon(polygon: polygon, points: airports);
    }
  }
}
