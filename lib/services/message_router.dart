import '../models/message.dart';

typedef MessageHandler = void Function(Message message);

class MessageRouter {
  final String myUsername;
  final MessageHandler onMessageForMe;
  final MessageHandler onForward;

  MessageRouter({
    required this.myUsername,
    required this.onMessageForMe,
    required this.onForward,
  });

  void receive(Message message) {
    // Drop expired messages
    if (message.ttl <= 0) return;

    // If message is for me → deliver
    if (message.receiverUsername == myUsername) {
      onMessageForMe(message);
      return;
    }

    // Otherwise forward blindly
    final forwarded = message.copyWith(ttl: message.ttl - 1);
    onForward(forwarded);
  }
}
