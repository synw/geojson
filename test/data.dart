String geojsonNestedGeometryCollection = """{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"name": "collection"},
      "geometry": {
        "type": "GeometryCollection",
        "geometries": [
          {
            "type": "GeometryCollection",
            "geometries": [
              {
                "type": "Point",
                "coordinates": [0, 0]
              },
              {
                "type": "Point",
                "coordinates": [1, 1]
              }
            ]
          },
          {
            "type": "Point",
            "coordinates": [0, 0]
          }
        ]
      }
    }
  ]
}""";
String geojsonPoint = """{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"name": "point"},
      "geometry": {
        "type": "Point",
        "coordinates": [0, 0]
      }
    }
  ]
}""";
String geojsonMultiPoint = """{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPoint",
        "coordinates": [[0, 0],[0, 0]] 
      }
    }
  ]
}""";
String geojsonLine = """{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"nameprop": "line"},
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [4e6, -2e6],
          [8e6, 2e6]
        ]
      }
    }
  ]
}""";
String geojsonMultiLine = """{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiLineString",
        "coordinates": [
          [
            [-1e6, -7.5e5],
            [-1e6, 7.5e5]
          ],
          [
            [1e6, -7.5e5],
            [1e6, 7.5e5]
          ],
          [
            [-7.5e5, -1e6],
            [7.5e5, -1e6]
          ],
          [
            [-7.5e5, 1e6],
            [7.5e5, 1e6]
          ]
        ]
      }
    }
  ]
}""";
String geojsonPolygon = """{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
            [-5e6, -1e6],
            [-4e6, 1e6],
            [-3e6, -1e6]
          ]
        ]
      }
    }
  ]
}""";
String geojsonMultiPolygon = """{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [-5e6, 6e6],
              [-5e6, 8e6],
              [-3e6, 8e6],
              [-3e6, 6e6]
            ]
          ],
          [
            [
              [-2e6, 6e6],
              [-2e6, 8e6],
              [0, 8e6],
              [0, 6e6]
            ]
          ],
          [
            [
              [1e6, 6e6],
              [1e6, 8e6],
              [3e6, 8e6],
              [3e6, 6e6]
            ]
          ]
        ]
      }
    }
  ]
}""";
String geojsonUnsupported = """{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"name": "point"},
      "geometry": {
        "type": "Unknown",
        "coordinates": [0, 0]
      }
    }
  ]
}""";
