/// An exception for code running in an isolate
class IsolateRuntimeError implements Exception {
  /// Provide a message
  IsolateRuntimeError(this.message);

  /// The error message
  final String message;
}
