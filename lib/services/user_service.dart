import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import 'dart:convert';

class UserService {
  static const _storage = FlutterSecureStorage();
  static const _usernameKey = 'sendtalk_username';
  static const _privateKeyKey = 'sendtalk_privateKey';
  static const _publicKeyKey = 'sendtalk_publicKey';

  static Future<String> getOrCreateUsername() async {
    String? username = await _storage.read(key: _usernameKey);
    if (username != null) return username;

    username = 'User${DateTime.now().millisecondsSinceEpoch}';
    await _storage.write(key: _usernameKey, value: username);
    return username;
  }

  static Future<Map<String, String>> generateKeyPair() async {
    String? privateKeyStr = await _storage.read(key: _privateKeyKey);
    String? publicKeyStr = await _storage.read(key: _publicKeyKey);

    if (privateKeyStr != null && publicKeyStr != null) {
      return {'privateKey': privateKeyStr, 'publicKey': publicKeyStr};
    }

    // Generate X25519 key pair
    final algorithm = X25519();
    final keyPair = await algorithm.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final privateKey = await keyPair.extractPrivateKeyBytes();

    // Store keys as base64 strings
    privateKeyStr = base64Encode(privateKey);
    publicKeyStr = base64Encode(publicKey.bytes);

    await _storage.write(key: _privateKeyKey, value: privateKeyStr);
    await _storage.write(key: _publicKeyKey, value: publicKeyStr);

    return {'privateKey': privateKeyStr, 'publicKey': publicKeyStr};
  }
}
