import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class IdentityService {
  static const String _uKey = 'id_username';
  static const String _prKey = 'id_private';
  static const String _pbKey = 'id_public';
  static const _storage = FlutterSecureStorage();

  static Future<void> initialize() async {
    final existing = await _storage.read(key: _uKey);
    if (existing != null) return;

    final algorithm = X25519();
    final keyPair = await algorithm.newKeyPair();
    final privBytes = await keyPair.extractPrivateKeyBytes();
    final pubBytes = (await keyPair.extractPublicKey()).bytes;

    // High entropy offline username
    final randomPart = Random.secure().nextInt(999999).toString().padLeft(6, '0');
    final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(16);

    await _storage.write(key: _uKey, value: 'st-$ts-$randomPart');
    await _storage.write(key: _prKey, value: base64Encode(privBytes));
    await _storage.write(key: _pbKey, value: base64Encode(pubBytes));
  }

  static Future<String> getUsername() async {
    return await _storage.read(key: _uKey) ?? 'Unknown';
  }

  static Future<List<int>> getPublicKey() async {
    final str = await _storage.read(key: _pbKey);
    return str != null ? base64Decode(str) : [];
  }

  // MUST NOT HAVE AN UNDERSCORE BEFORE THE NAME
  static Future<List<int>> getPrivateKey() async {
    final str = await _storage.read(key: _prKey);
    return str != null ? base64Decode(str) : [];
  }
}