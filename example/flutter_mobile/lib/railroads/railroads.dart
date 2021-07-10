import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson/geojson.dart';
import 'package:latlong2/latlong.dart';

class _RailroadsPageState extends State<RailroadsPage> {
  final lines = <Polyline>[];

  @override
  void initState() {
    processData();
    super.initState();
  }

  Future<void> processData() async {
    // data is from http://www.naturalearthdata.com
    final data = await rootBundle
        .loadString('assets/railroads_of_north_america.geojson');
    final geojson = GeoJson();
    geojson.processedLines.listen((GeoJsonLine line) {
      final color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(0.3);
      setState(() => lines.add(Polyline(
          strokeWidth: 2.0, color: color, points: line.geoSerie!.toLatLng())));
    });
    geojson.endSignal.listen((_) => geojson.dispose());
    unawaited(geojson.parse(data, verbose: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FlutterMap(
      mapController: MapController(),
      options: MapOptions(
        center: LatLng(43.91941, -99.84619),
        zoom: 3.0,
      ),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        PolylineLayerOptions(polylines: lines),
      ],
    ));
  }
}

class RailroadsPage extends StatefulWidget {
  @override
  _RailroadsPageState createState() => _RailroadsPageState();
}
