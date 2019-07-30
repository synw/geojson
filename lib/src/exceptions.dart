/// An exception for when a feauture is not supported
class FeatureNotSupported implements Exception {
  /// Pass the feature name
  FeatureNotSupported(this.feature) {
    message = "The feature $feature is not supported";
  }

  /// The feature
  final String feature;

  /// The exception message
  String message;
}
