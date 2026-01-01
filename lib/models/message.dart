class Message {
  final String id;
  final String senderUsername;
  final String receiverUsername;
  final String cipherText;
  final String senderPublicKey;
  final DateTime timestamp;
  final bool isMe;

  // Routing
  final int ttl; // time-to-live / hop count

  Message({
    required this.id,
    required this.senderUsername,
    required this.receiverUsername,
    required this.cipherText,
    required this.senderPublicKey,
    required this.timestamp,
    required this.isMe,
    this.ttl = 5, // default hops
  });

  Message copyWith({int? ttl}) {
    return Message(
      id: id,
      senderUsername: senderUsername,
      receiverUsername: receiverUsername,
      cipherText: cipherText,
      senderPublicKey: senderPublicKey,
      timestamp: timestamp,
      isMe: isMe,
      ttl: ttl ?? this.ttl,
    );
  }
}
