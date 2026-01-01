import 'dart:convert';
import 'dart:io';
import '../models/message_envelope.dart';
import '../models/peer.dart';

class TcpMessagingService {
  final List<Peer> peers;
  ServerSocket? _server;
  final Function(MessageEnvelope) onIncomingEnvelope;

  // This constructor must match RoutingService call
  TcpMessagingService(this.peers, {required this.onIncomingEnvelope});

  Future<void> startServer() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 5678);
    _server!.listen((Socket client) {
      client.listen((data) {
        try {
          final String rawString = utf8.decode(data);
          final Map<String, dynamic> json = jsonDecode(rawString);
          
          // These methods are now defined in MessageEnvelope
          final envelope = MessageEnvelope.fromJson(json);
          
          onIncomingEnvelope(envelope);
          
          // Forwarding logic for Mesh
          _forward(envelope, exclude: client.remoteAddress.address);
        } catch (e) {
          print('TCP Read Error: $e');
        }
      });
    });
  }

  Future<void> send(MessageEnvelope envelope, Peer peer) async {
    try {
      final socket = await Socket.connect(peer.address, peer.port, timeout: const Duration(seconds: 2));
      socket.write(jsonEncode(envelope.toJson()));
      await socket.flush();
      await socket.close();
    } catch (e) {
      print('TCP Send Error to ${peer.username}: $e');
    }
  }

  void _forward(MessageEnvelope envelope, {required String exclude}) {
    for (var peer in peers) {
      if (peer.address != exclude) {
        send(envelope, peer);
      }
    }
  }
}