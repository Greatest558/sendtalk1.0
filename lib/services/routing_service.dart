import 'package:flutter/foundation.dart'; // Required for ValueNotifier
import '../models/message_envelope.dart';
import 'discovery_service.dart';
import 'tcp_messaging_service.dart';

class RoutingService {
  static final RoutingService instance = RoutingService._();
  RoutingService._();

  final DiscoveryService _discovery = DiscoveryService();
  TcpMessagingService? _tcp; 
  final Set<String> _seenMessageIds = {}; 

  // This allows the UI to listen for peer count changes automatically
  final ValueNotifier<int> peerCountNotifier = ValueNotifier<int>(0);

  Function(MessageEnvelope)? onNewMessage;

  Future<void> init() async {
    _tcp = TcpMessagingService(
      _discovery.peers, 
      onIncomingEnvelope: (envelope) {
        final msgId = "${envelope.senderUsername}_${envelope.timestamp}";
        if (_seenMessageIds.contains(msgId)) return;
        _seenMessageIds.add(msgId);
        
        if (onNewMessage != null) onNewMessage!(envelope);
      }
    );

    await _discovery.start();
    
    // Periodically update the peer count notifier
    _updatePeerCountLoop();

    await _tcp!.startServer();
  }

  // Helper to keep the notifier updated
  void _updatePeerCountLoop() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      peerCountNotifier.value = _discovery.peers.length;
    }
  }

  // This fixes the red underline in your ChatScreen
  int getPeerCount() {
    return _discovery.peers.length;
  }

  void routeMessage(MessageEnvelope envelope) {
    if (_tcp == null) return;
    for (var peer in _discovery.peers) {
      _tcp!.send(envelope, peer);
    }
  }
}