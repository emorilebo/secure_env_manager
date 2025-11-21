import 'dart:io';
import '../encryption/encryption_service.dart';

/// Runtime access to environment configuration.
/// This is a placeholder that will be replaced by generated code.
class EnvConfig {
  EnvConfig._();

  static EnvConfig? _instance;
  static EnvConfig get instance {
    _instance ??= EnvConfig._();
    return _instance!;
  }

  static String? _masterKey;

  /// Sets the master key for decryption.
  static void setMasterKey(String key) {
    _masterKey = key;
  }

  /// Gets a string value from environment.
  static String? getString(String key, {String? defaultValue}) {
    final value = Platform.environment[key];
    if (value == null) return defaultValue;
    
    if (EncryptionService.isEncrypted(value)) {
      if (_masterKey == null) {
        throw StateError('Master key not set. Call EnvConfig.setMasterKey() first.');
      }
      return EncryptionService.decrypt(value, _masterKey!);
    }
    
    return value;
  }

  /// Gets an integer value from environment.
  static int? getInt(String key, {int? defaultValue}) {
    final value = getString(key);
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Gets a boolean value from environment.
  static bool? getBool(String key, {bool? defaultValue}) {
    final value = getString(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Gets a double value from environment.
  static double? getDouble(String key, {double? defaultValue}) {
    final value = getString(key);
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }
}


