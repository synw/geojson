import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'process_data.dart';

class _RailroadsPageState extends State<RailroadsPage> {
  List<Polyline> lines;
  bool ready = false;

  @override
  void initState() {
    final proc = DataProcessor();
    proc.run().then((_) {
      print("Drawing ${proc.lines.length} lines");
      lines = proc.lines;
      setState(() => ready = true);
      print("Points on map: ${proc.numPoints}");
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
                center: LatLng(43.91941, -99.84619),
                zoom: 3.0,
              ),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']),
                PolylineLayerOptions(polylines: lines),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class RailroadsPage extends StatefulWidget {
  @override
  _RailroadsPageState createState() => _RailroadsPageState();
}
