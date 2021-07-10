/// An exception for when a feauture is not supported
class FeatureNotSupported implements Exception {
  /// Pass the feature name
  FeatureNotSupported(this.feature) {
    message = "The feature $feature is not supported";
  }

  /// The feature
  final String feature;

  /// The exception message
  String? message;
}

/// An exception for file manipulation
class FileSystemException implements Exception {
  /// Pass the message
  FileSystemException(this.message);

  /// The exception message
  String message;
}

/// An exception for parsing errors
class ParseErrorException implements Exception {
  /// Pass the message
  ParseErrorException(this.message);

  /// The exception message
  String message;
}

/// An exception for geofencing errors
class GeofencingException implements Exception {
  /// Pass the message
  GeofencingException(this.message);

  /// The exception message
  String message;
}
