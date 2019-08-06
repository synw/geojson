import 'package:flutter/material.dart';
import 'countries/countries.dart';
import 'railroads/railroads.dart';
import 'index.dart';

final routes = {
  '/countries': (BuildContext context) => CountriesPage(),
  '/railroads': (BuildContext context) => RailroadsPage(),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geojson Flutter example',
      home: IndexPage(),
      routes: routes,
    );
  }
}

void main() => runApp(MyApp());
