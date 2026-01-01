class MessageEnvelope {
  final String senderUsername;
  final List<int> senderPublicKey;
  final String cipherPayload;
  final int timestamp;

  MessageEnvelope({
    required this.senderUsername,
    required this.senderPublicKey,
    required this.cipherPayload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'senderUsername': senderUsername,
        'senderPublicKey': senderPublicKey,
        'cipherPayload': cipherPayload,
        'timestamp': timestamp,
      };

  factory MessageEnvelope.fromJson(Map<String, dynamic> json) {
    return MessageEnvelope(
      senderUsername: json['senderUsername'] as String,
      senderPublicKey: (json['senderPublicKey'] as List).cast<int>(),
      cipherPayload: json['cipherPayload'] as String,
      timestamp: json['timestamp'] as int,
    );
  }
}