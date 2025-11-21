import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'dart:typed_data';

/// Service for encrypting and decrypting environment variable values.
class EncryptionService {
  /// Encrypts a value using AES encryption.
  static String encrypt(String value, String masterKey) {
    try {
      // Generate a key from the master key (32 bytes for AES-256)
      final key = _deriveKey(masterKey);
      final iv = IV.fromLength(16);

      final encrypter = Encrypter(AES(key));
      final encrypted = encrypter.encrypt(value, iv: iv);

      // Return base64 encoded IV + encrypted data
      final combined = '${iv.base64}:${encrypted.base64}';
      return base64Encode(utf8.encode(combined));
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypts an encrypted value.
  static String decrypt(String encryptedValue, String masterKey) {
    try {
      // Decode from base64
      final decoded = utf8.decode(base64Decode(encryptedValue));
      final parts = decoded.split(':');
      if (parts.length != 2) {
        throw const FormatException('Invalid encrypted format');
      }

      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);

      // Generate key from master key
      final key = _deriveKey(masterKey);
      final encrypter = Encrypter(AES(key));

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Derives a 32-byte key from the master key.
  static Key _deriveKey(String masterKey) {
    // Simple key derivation: pad or truncate to 32 bytes
    final bytes = utf8.encode(masterKey);
    final keyBytes = Uint8List(32);

    for (int i = 0; i < 32; i++) {
      keyBytes[i] = bytes[i % bytes.length];
    }

    return Key(keyBytes);
  }

  /// Checks if a value is encrypted (starts with encrypted prefix).
  static bool isEncrypted(String value) {
    try {
      // Try to decode as base64
      final decoded = utf8.decode(base64Decode(value));
      return decoded.contains(':');
    } catch (e) {
      return false;
    }
  }
}

