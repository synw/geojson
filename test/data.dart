var geojsonPoint = """{
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
var geojsonMultiPoint = """{
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
var geojsonLine = """{
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
var geojsonMultiLine = """{
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
var geojsonPolygon = """{
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
var geojsonMultiPolygon = """{
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
var geojsonUnsupported = """{
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
