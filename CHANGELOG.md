# Changelog

## 1.0.0

Migration to null safety

## 0.10.0

- Update dependencies
- Don't serialize null name to 'name: "null"'
- Process nested geometry collections

## 0.9.1

- Include point properties in serialization
- Document the web support

## 0.9.0

- Add a parse in main thread method for web compatibility
- Add altitude to GeoPoint if available
- Update the flutter map example

## 0.8.0

Add support for parsing `GeometryCollection` objects

## 0.7.3

Include feature properties when serializing

## 0.7.2

Fix in `GeoJsonQuery` serializer

## 0.7.1

Fix `GeoJsonFeatureCollection` serializer

## 0.7.0

- Fix polygon serialization
- Update dependencies
- Improve the exceptions management
- Improve the documentation
- Use stronger analysis options

## 0.6.0

- Add search methods
- Add geofencing methods
- Add serializers

## 0.5.0

**Breaking change**: prefix all classes names by `GeoJson`

## 0.4.0

Add a reactive api with streams to retrive features as soon as they are parsed

## 0.3.0

- Run the parser in an isolate
- Add a `feature.length` getter
- Upgrade dependencies
- Add examples for drawing on a Flutter map

## 0.2.3

- Add tests
- Fix coordinates in getPoint
- Fix name parameter for Point
- Fix unsupported feature exception throw

## 0.2.2

- Add custom exception for unsupported features
- Use type parameter for feature geometry instead of dynamic
- Avoid failure when no json properties are found

## 0.2.1

Fix latitude and longitude invertion

## 0.2.0

**Api change**: add models and dedicated data structures

## 0.1.0

Initial release
