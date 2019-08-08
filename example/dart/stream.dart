import 'package:geojson/geojson.dart';

void main() {
  smallData();
}

Future<void> smallData() async {
  final geojson = GeoJson();
  geojson.processedPoints.listen((GeoJsonPoint point) {
    print("Point: ${point.geoPoint}");
  });
  await geojson.parseFile("../data/small_data.geojson", verbose: true);
}
