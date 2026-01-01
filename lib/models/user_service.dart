class Peer {
  final String username;
  final List<int> publicKey;
  final String address; // IP or host
  int port;

  Peer({
    required this.username,
    required this.publicKey,
    required this.address,
    required this.port,
  });
}
