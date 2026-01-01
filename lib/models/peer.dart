class Peer {
  final String username;
  final List<int> publicKey;
  final String address;
  final int port;
  DateTime lastSeen;

  Peer({
    required this.username,
    required this.publicKey,
    required this.address,
    required this.port,
  }) : lastSeen = DateTime.now();
}