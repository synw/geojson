import 'package:geojson/geojson.dart';

void main() {
  parse();
}

Future<void> parse() async {
  final geojson = GeoJson();
  geojson.processedMultiPolygons.listen((GeoJsonMultiPolygon multiPolygon) {
    print("${multiPolygon.name}: ${multiPolygon.polygons.length} polygon(s)");
  });
  await geojson.parseFile("../flutter_map/assets/countries.geojson",
      nameProperty: "ADMIN");
}
