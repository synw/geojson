import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson/geojson.dart';
import 'package:latlong2/latlong.dart';
import 'package:geopoint/geopoint.dart';
import 'package:flutter_map/flutter_map.dart';

class _NearbyAirportsPageState extends State<NearbyAirportsPage> {
  final mapController = MapController();
  final markers = <Marker>[];
  var airportsData = <GeoJsonPoint>[];
  final geo = GeoJson();
  late StreamSubscription<GeoJsonPoint> sub;
  final dataIsLoaded = Completer<Null>();
  String status = "Loading data ...";

  @override
  void initState() {
    super.initState();
    loadAirports().then((_) {
      dataIsLoaded.complete();
      setState(() => status = "Tap on map to search for airports");
    });
    sub = geo.processedPoints.listen((point) {
      // listen for the geofenced airports
      setState(() => markers.add(Marker(
          point: point.geoPoint.toLatLng()!,
          builder: (BuildContext context) => Icon(Icons.local_airport))));
    });
  }

  Future<void> searchNearbyAirports(LatLng point) async {
    // draw tapped point
    setState(() => markers.add(Marker(
        point: point,
        builder: (BuildContext context) => Icon(
              Icons.location_on,
              color: Colors.red,
            ))));
    await dataIsLoaded.future;
    // geofence in radius
    final kilometers = 500;
    final geoJsonPoint = GeoJsonPoint(
        geoPoint:
            GeoPoint(latitude: point.latitude, longitude: point.longitude));
    await geo.geofenceDistance(
        point: geoJsonPoint, points: airportsData, distance: kilometers * 1000);
  }

  Future<void> loadAirports() async {
    final data = await rootBundle.loadString('assets/airports.geojson');
    await geo.parse(data, disableStream: true, verbose: true);
    airportsData = geo.points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
                center: LatLng(51.0, 0),
                zoom: 4.0,
                onTap: searchNearbyAirports),
            layers: [
              TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              MarkerLayerOptions(markers: markers)
            ],
          ),
          Positioned(
            child: Text(status),
            left: 15.0,
            bottom: 20.0,
          )
        ],
      )),
    );
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}

class NearbyAirportsPage extends StatefulWidget {
  @override
  _NearbyAirportsPageState createState() => _NearbyAirportsPageState();
}
