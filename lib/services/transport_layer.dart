import '../models/message.dart';

typedef TransportReceiveCallback = void Function(Message message);

class TransportLayer {
  final TransportReceiveCallback onReceive;

  TransportLayer({required this.onReceive});

  /// Send a message to peers (offline mesh or online fallback)
  Future<void> send(Message message) async {
    // TODO: Implement actual transport:
    // 1. Wi-Fi Direct
    // 2. Bluetooth
    // 3. Internet fallback
    //
    // For now, simulate delayed delivery to self/peers
    Future.delayed(const Duration(milliseconds: 500), () {
      onReceive(message);
    });
  }

  /// Handle incoming message from any peer
  void receive(Message message) {
    onReceive(message);
  }
}
