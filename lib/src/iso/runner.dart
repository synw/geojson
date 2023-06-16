import 'dart:isolate';

/// The isolate runner
class IsoRunner {
  /// A [chanOut] has to be provided
  IsoRunner({required this.chanOut, this.dataIn, this.args})
      : assert(chanOut != null);

  /// The [SendPort] to send data into the isolate
  final SendPort chanOut;

  /// The [ReceivePort] to reveive data in the isolate
  ReceivePort? dataIn;

  /// The arguments for the run function
  List<dynamic>? args;

  /// Does the run function has arguments
  bool get hasArgs => args!.isNotEmpty;

  /// Send data to the main thread
  void send(dynamic data) => chanOut.send(data);

  /// Initialize the receive channel
  ///
  /// This must be done before sending messages into the isolate
  /// after this the [Iso.onCanReceive] future will be completed
  ReceivePort receive() {
    final listener = ReceivePort();
    send(listener.sendPort);
    dataIn = listener;
    return listener;
  }
}
