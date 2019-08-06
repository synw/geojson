import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'process_data.dart';

class _CountriesPageState extends State<CountriesPage> {
  final polygons = <Polygon>[];
  bool ready = false;

  @override
  void initState() {
    final proc = DataProcessor();
    int numPoints = 0;
    proc.run().then((_) {
      proc.countries.forEach((name, polygon) {
        polygons.add(polygon);
        print("$name : ${polygon.points.length} points");
        numPoints = numPoints + polygon.points.length;
      });
      setState(() => ready = true);
      print("Points on map: $numPoints");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ready
          ? FlutterMap(
              mapController: MapController(),
              options: MapOptions(
                center: LatLng(51.0, 0.0),
                zoom: 3.0,
              ),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']),
                PolygonLayerOptions(
                  polygons: polygons,
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class CountriesPage extends StatefulWidget {
  @override
  _CountriesPageState createState() => _CountriesPageState();
}
