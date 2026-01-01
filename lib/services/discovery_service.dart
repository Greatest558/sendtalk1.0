import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../services/identity_service.dart';
import '../models/peer.dart';

class DiscoveryService {
  static const int broadcastPort = 4567;
  final List<Peer> peers = [];
  late RawDatagramSocket _socket;
  Timer? _broadcastTimer;
  String? _myUsername;

  Future<void> start() async {
    _myUsername = await IdentityService.getUsername();
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, broadcastPort);
    _socket.broadcastEnabled = true;
    _socket.listen(_onPacketReceived);

    _broadcastTimer = Timer.periodic(const Duration(seconds: 5), (_) => _broadcastIdentity());
  }

  void _onPacketReceived(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _socket.receive();
    if (datagram == null) return;

    try {
      final data = jsonDecode(utf8.decode(datagram.data));
      final String username = data['username'];
      if (username == _myUsername) return;

      final existingIndex = peers.indexWhere((p) => p.username == username);
      if (existingIndex == -1) {
        peers.add(Peer(
          username: username,
          publicKey: (data['publicKey'] as List).cast<int>(),
          address: datagram.address.address,
          port: data['port'],
        ));
      } else {
        peers[existingIndex].lastSeen = DateTime.now();
      }
    } catch (_) {}
  }

  Future<void> _broadcastIdentity() async {
    final payload = jsonEncode({
      'username': await IdentityService.getUsername(),
      'publicKey': await IdentityService.getPublicKey(),
      'port': 5678, // TCP Listening Port
    });
    _socket.send(utf8.encode(payload), InternetAddress('255.255.255.255'), broadcastPort);
  }

  void stop() {
    _broadcastTimer?.cancel();
    _socket.close();
  }
}