import 'package:flutter/material.dart';
import '../services/identity_service.dart';
import '../services/crypto_service.dart';
import '../services/routing_service.dart';
import '../models/message_envelope.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<MessageEnvelope> _messages = [];
  final Map<MessageEnvelope, String> _decryptedCache = {};
  final TextEditingController _controller = TextEditingController();

  bool _ready = false;
  late List<int> _myPublicKey;
  late List<int> _myPrivateKey;

  @override
  void initState() {
    super.initState();
    _initMesh();
  }

  Future<void> _initMesh() async {
    await IdentityService.initialize();
    _myPublicKey = await IdentityService.getPublicKey();
    _myPrivateKey = await IdentityService.getPrivateKey();

    await RoutingService.instance.init();
    RoutingService.instance.onNewMessage = _handleIncoming;

    setState(() => _ready = true);
  }

  void _handleIncoming(MessageEnvelope envelope) async {
    try {
      final decrypted = await CryptoService.decrypt(
        cipherPayload: envelope.cipherPayload,
        receiverPrivateKey: _myPrivateKey,
        receiverPublicKey: _myPublicKey,
        senderPublicKey: envelope.senderPublicKey,
      );
      setState(() {
        _messages.add(envelope);
        _decryptedCache[envelope] = decrypted;
      });
    } catch (_) {} 
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final myUsername = await IdentityService.getUsername();
    
    final cipher = await CryptoService.encrypt(
      plainText: text,
      senderPrivateKey: _myPrivateKey,
      senderPublicKey: _myPublicKey,
      receiverPublicKey: _myPublicKey, 
    );

    final env = MessageEnvelope(
      senderUsername: myUsername,
      senderPublicKey: _myPublicKey,
      cipherPayload: cipher,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.add(env);
      _decryptedCache[env] = text;
    });

    RoutingService.instance.routeMessage(env);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('SendTalk Mesh'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.hub, size: 18, color: Colors.greenAccent),
                  const SizedBox(width: 4),
                  Text(
                    '${RoutingService.instance.getPeerCount()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final env = _messages[index];
                return ListTile(
                  title: Text(env.senderUsername, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_decryptedCache[env] ?? '[Encrypted Content]'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, onSubmitted: (_) => _sendMessage())),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          )
        ],
      ),
    );
  }
}