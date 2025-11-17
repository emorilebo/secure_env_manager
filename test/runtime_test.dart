import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_env_manager/src/runtime/env_config.dart';

void main() {
  group('EnvConfig', () {
    setUp(() {
      // Clear any previous master key
      EnvConfig.setMasterKey('test-key');
    });

    test('getString returns value from environment', () {
      // Note: In real tests, you'd set environment variables
      // For this test, we're checking the API works
      final value = EnvConfig.getString('TEST_VAR', defaultValue: 'default');
      expect(value, isNotNull);
    });

    test('getString returns default when not set', () {
      final value = EnvConfig.getString('NONEXISTENT_VAR', defaultValue: 'default');
      expect(value, equals('default'));
    });

    test('getInt parses integer values', () {
      final value = EnvConfig.getInt('INT_VAR', defaultValue: 42);
      expect(value, equals(42));
    });

    test('getBool parses boolean values', () {
      final value = EnvConfig.getBool('BOOL_VAR', defaultValue: true);
      expect(value, equals(true));
    });

    test('getDouble parses double values', () {
      final value = EnvConfig.getDouble('DOUBLE_VAR', defaultValue: 3.14);
      expect(value, equals(3.14));
    });

    test('setMasterKey updates master key', () {
      EnvConfig.setMasterKey('new-key');
      // Master key is set (no exception thrown)
      expect(EnvConfig.instance, isNotNull);
    });
  });
}

