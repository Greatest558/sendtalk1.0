import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  static final X25519 _algorithm = X25519();
  static final AesGcm _cipher = AesGcm.with256bits();

  /// Encrypt message
  static Future<String> encrypt({
    required String plainText,
    required List<int> senderPrivateKey,
    required List<int> senderPublicKey,
    required List<int> receiverPublicKey,
  }) async {
    // Reconstruct the sender's key pair
    final senderKeyPair = SimpleKeyPairData(
      senderPrivateKey,
      publicKey: SimplePublicKey(senderPublicKey, type: KeyPairType.x25519),
      type: KeyPairType.x25519,
    );

    // Reconstruct the receiver's public key
    final receiverPublicKeyObj = SimplePublicKey(
      receiverPublicKey,
      type: KeyPairType.x25519,
    );

    // Calculate Shared Secret
    final sharedSecret = await _algorithm.sharedSecretKey(
      keyPair: senderKeyPair,
      remotePublicKey: receiverPublicKeyObj,
    );

    // Encrypt using the shared secret directly as the key
    final nonce = _cipher.newNonce();
    final secretBox = await _cipher.encrypt(
      utf8.encode(plainText),
      secretKey: sharedSecret,
      nonce: nonce,
    );

    // Return: Nonce (12 bytes) + CipherText + MAC (16 bytes)
    return base64Encode(
      nonce + secretBox.cipherText + secretBox.mac.bytes,
    );
  }

  /// Decrypt message
  static Future<String> decrypt({
    required String cipherPayload,
    required List<int> receiverPrivateKey,
    required List<int> receiverPublicKey,
    required List<int> senderPublicKey,
  }) async {
    try {
      final data = base64Decode(cipherPayload);

      final receiverKeyPair = SimpleKeyPairData(
        receiverPrivateKey,
        publicKey: SimplePublicKey(receiverPublicKey, type: KeyPairType.x25519),
        type: KeyPairType.x25519,
      );

      final senderPublicKeyObj = SimplePublicKey(
        senderPublicKey,
        type: KeyPairType.x25519,
      );

      final sharedSecret = await _algorithm.sharedSecretKey(
        keyPair: receiverKeyPair,
        remotePublicKey: senderPublicKeyObj,
      );

      // AES-GCM standard: 12 byte nonce, last 16 bytes is MAC
      final nonce = data.sublist(0, 12);
      final cipherText = data.sublist(12, data.length - 16);
      final macBytes = data.sublist(data.length - 16);

      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: Mac(macBytes),
      );

      final clearText = await _cipher.decrypt(
        secretBox,
        secretKey: sharedSecret,
      );

      return utf8.decode(clearText);
    } catch (e) {
      return '[Decryption failed]';
    }
  }
}