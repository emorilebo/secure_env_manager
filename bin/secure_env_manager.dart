#!/usr/bin/env dart

import 'dart:io';
import 'package:secure_env_manager/secure_env_manager.dart';
import 'package:secure_env_manager/src/encryption/encryption_service.dart';

/// CLI tool for secure_env_manager operations.
void main(List<String> args) async {
  if (args.isEmpty) {
    _printUsage();
    exit(1);
  }

  final command = args[0];

  switch (command) {
    case 'generate':
      await _generateConfig();
      break;
    case 'encrypt':
      if (args.length < 3) {
        print('Usage: secure_env_manager encrypt <value> <master-key>');
        exit(1);
      }
      _encryptValue(args[1], args[2]);
      break;
    case 'decrypt':
      if (args.length < 3) {
        print('Usage: secure_env_manager decrypt <encrypted-value> <master-key>');
        exit(1);
      }
      _decryptValue(args[1], args[2]);
      break;
    case 'validate':
      await _validateSchema();
      break;
    default:
      print('Unknown command: $command');
      _printUsage();
      exit(1);
  }
}

void _printUsage() {
  print('''
Secure Environment Manager CLI

Usage:
  secure_env_manager <command> [arguments]

Commands:
  generate              Generate EnvConfig class from schema
  encrypt <value> <key> Encrypt a value with master key
  decrypt <value> <key> Decrypt an encrypted value
  validate              Validate env_schema.yaml

Examples:
  secure_env_manager generate
  secure_env_manager encrypt "my-secret" "my-master-key"
  secure_env_manager decrypt "encrypted-value" "my-master-key"
''');
}

Future<void> _generateConfig() async {
  try {
    final schema = SchemaLoader.loadFromProject();
    schema.validate();
    print('✓ Schema validated successfully');
    print('✓ Found ${schema.fields.length} fields');
    print('\nRun: flutter pub run build_runner build');
  } catch (e) {
    print('✗ Error: $e');
    exit(1);
  }
}

void _encryptValue(String value, String masterKey) {
  try {
    final encrypted = EncryptionService.encrypt(value, masterKey);
    print('Encrypted value:');
    print(encrypted);
  } catch (e) {
    print('✗ Encryption failed: $e');
    exit(1);
  }
}

void _decryptValue(String encryptedValue, String masterKey) {
  try {
    final decrypted = EncryptionService.decrypt(encryptedValue, masterKey);
    print('Decrypted value:');
    print(decrypted);
  } catch (e) {
    print('✗ Decryption failed: $e');
    exit(1);
  }
}

Future<void> _validateSchema() async {
  try {
    final schema = SchemaLoader.loadFromProject();
    schema.validate();
    print('✓ Schema is valid');
    print('✓ Fields: ${schema.fields.length}');
    for (final field in schema.fields) {
      print('  - ${field.name} (${field.type})${field.required ? " [required]" : ""}${field.encrypted ? " [encrypted]" : ""}');
    }
  } catch (e) {
    print('✗ Validation failed: $e');
    exit(1);
  }
}

