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
          property: "ADMIN",
          value: countryName),
      nameProperty: "ADMIN",
      verbose: true);
  if (geo.multipolygons.isEmpty) {
    print("Country $countryName not found");
    return;
  }
  final country = geo.multipolygons[0];
  print("Loading airports");
  geo.processedPoints.listen((GeoJsonPoint point) {});
  await geo.parseFile("../data/airports.geojson");
  final airports = geo.points;
  print("Loaded ${airports.length} airports");
  print("Geofencing airports in $countryName");
  print("Airports in $countryName:");
  final foundAirports = <GeoJsonPoint>[];
  for (final polygon in country.polygons) {
    final found = await geo.geofence(polygon: polygon, points: airports);
    foundAirports.addAll(found);
    for (final airport in found) {
      print("  - ${airport.name}");
    }
  }
  print("Found ${foundAirports.length} airports in $countryName");
}
