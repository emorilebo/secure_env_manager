import 'package:flutter_test/flutter_test.dart';
import 'package:secure_env_manager/src/encryption/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    const masterKey = 'test-master-key-12345';
    const testValue = 'my-secret-value';

    test('encrypts and decrypts value', () {
      final encrypted = EncryptionService.encrypt(testValue, masterKey);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(testValue)));

      final decrypted = EncryptionService.decrypt(encrypted, masterKey);
      expect(decrypted, equals(testValue));
    });

    test('encryption produces different output each time', () {
      final encrypted1 = EncryptionService.encrypt(testValue, masterKey);
      final encrypted2 = EncryptionService.encrypt(testValue, masterKey);

      // Should be different due to random IV
      expect(encrypted1, isNot(equals(encrypted2)));

      // But both should decrypt to same value
      expect(
        EncryptionService.decrypt(encrypted1, masterKey),
        equals(testValue),
      );
      expect(
        EncryptionService.decrypt(encrypted2, masterKey),
        equals(testValue),
      );
    });

    test('decryption fails with wrong key', () {
      final encrypted = EncryptionService.encrypt(testValue, masterKey);
      const wrongKey = 'wrong-key';

      expect(
        () => EncryptionService.decrypt(encrypted, wrongKey),
        throwsException,
      );
    });

    test('isEncrypted detects encrypted values', () {
      final encrypted = EncryptionService.encrypt(testValue, masterKey);
      expect(EncryptionService.isEncrypted(encrypted), true);
      expect(EncryptionService.isEncrypted(testValue), false);
      expect(EncryptionService.isEncrypted('plain-text'), false);
    });

    test('handles empty string', () {
      const emptyValue = '';
      final encrypted = EncryptionService.encrypt(emptyValue, masterKey);
      final decrypted = EncryptionService.decrypt(encrypted, masterKey);
      expect(decrypted, equals(emptyValue));
    });

    test('handles special characters', () {
      const specialValue = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
      final encrypted = EncryptionService.encrypt(specialValue, masterKey);
      final decrypted = EncryptionService.decrypt(encrypted, masterKey);
      expect(decrypted, equals(specialValue));
    });
  });
}

