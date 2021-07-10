import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson/geojson.dart';
import 'package:latlong2/latlong.dart';

class _AirportsPageState extends State<AirportsPage> {
  final polygons = <Polygon>[];
  final markers = <Marker>[];
  final controller = TextEditingController();
  final subject = PublishSubject<String>();
  final geo = GeoJson();
  var countriesToSelect = <GeoJsonMultiPolygon>[];
  var countriesData = <GeoJsonMultiPolygon>[];
  var airportsData = <GeoJsonPoint>[];
  final mapController = MapController();
  late StreamSubscription<GeoJsonPoint> sub;
  bool isSearching = false;
  bool dataIsLoaded = false;
  bool showSearchResults = false;

  @override
  void initState() {
    super.initState();
    loadCountries().then(
        (_) => loadAirports().then((_) => setState(() => dataIsLoaded = true)));
    subject.debounceTime(Duration(milliseconds: 500)).listen((text) async {
      if (!isSearching) {
        isSearching = true;
        final _countries = await searchCountries(text);
        setState(() {
          countriesToSelect = _countries;
          showSearchResults = true;
        });
        isSearching = false;
      }
    });
    sub = geo.processedPoints.listen((geojsonPoint) {
      // listen for the geofenced airports
      final point = geojsonPoint.geoPoint.toLatLng()!;
      setState(() => markers.add(Marker(
          point: point,
          builder: (BuildContext context) => Icon(Icons.local_airport))));
    });
  }

  Future<void> loadCountries() async {
    final data = await rootBundle.loadString('assets/countries.geojson');
    await geo.parse(data,
        nameProperty: "ADMIN", disableStream: true, verbose: true);
    countriesData = geo.multiPolygons;
  }

  Future<void> loadAirports() async {
    final data = await rootBundle.loadString('assets/airports.geojson');
    await geo.parse(data, disableStream: true, verbose: true);
    airportsData = geo.points;
  }

  Future<List<GeoJsonMultiPolygon>> searchCountries(String name) async {
    print('Searching for countries: $name');
    final foundCountries = <GeoJsonMultiPolygon>[];
    for (final c in countriesData) {
      if (c.name == null) return foundCountries;
      if (c.name!.toLowerCase().startsWith(name.toLowerCase())) {
        foundCountries.add(c);
      }
    }
    return foundCountries;
  }

  Future<void> airportsInCountries(GeoJsonMultiPolygon _country) async {
    print("Airports in ${_country.name}");
    int i = 0;
    for (final polygon in _country.polygons) {
      print("Processing polygon $i");
      // draw country polygon
      for (final geoSerie in polygon.geoSeries) {
        setState(() => polygons
            .add(Polygon(points: geoSerie.toLatLng(ignoreErrors: true))));
      }
      // geofence airports
      await geo.geofencePolygon(
          polygon: polygon, points: airportsData, verbose: true);
      ++i;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(
      children: <Widget>[
        FlutterMap(
          mapController: mapController,
          options: MapOptions(center: LatLng(51.0, 0), zoom: 2.0),
          layers: [
            TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
            PolygonLayerOptions(polygons: polygons),
            MarkerLayerOptions(markers: markers)
          ],
        ),
        Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: dataIsLoaded
                                ? TextField(
                                    controller: controller,
                                    onChanged: (text) => subject.add(text),
                                  )
                                : const Text("Loading data ...",
                                    textScaleFactor: 1.2)),
                        dataIsLoaded ? Icon(Icons.search) : const Text("")
                      ],
                    )),
                if (showSearchResults)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: countriesToSelect.length,
                    itemBuilder: (BuildContext context, int i) {
                      return ListTile(
                          title: GestureDetector(
                              child: Text(countriesToSelect[i].name ?? ""),
                              onTap: () {
                                final country = countriesToSelect[i];
                                setState(() {
                                  countriesToSelect = <GeoJsonMultiPolygon>[];
                                  FocusScope.of(context).unfocus();
                                  showSearchResults = false;
                                });
                                airportsInCountries(country);
                              }));
                    },
                  ),
              ],
            )),
      ],
    )));
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}

class AirportsPage extends StatefulWidget {
  @override
  _AirportsPageState createState() => _AirportsPageState();
}
