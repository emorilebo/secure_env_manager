import 'package:flutter_test/flutter_test.dart';
import 'package:secure_env_manager/src/builder/env_config_generator.dart';
import 'package:secure_env_manager/src/schema/env_schema.dart';
import 'package:secure_env_manager/src/schema/env_field.dart';

void main() {
  group('EnvConfigGenerator', () {
    test('generates code for simple schema', () {
      final schema = EnvSchema(
        fields: [
          const EnvField(
            name: 'API_URL',
            type: 'String',
            required: true,
          ),
        ],
      );

      final generator = EnvConfigGenerator(schema: schema);
      final code = generator.generate();

      expect(code, contains('class EnvConfig'));
      expect(code, contains('apiUrl'));
      expect(code, contains('API_URL'));
    });

    test('generates code with default values', () {
      final schema = EnvSchema(
        fields: [
          const EnvField(
            name: 'PORT',
            type: 'int',
            defaultValue: 8080,
          ),
        ],
      );

      final generator = EnvConfigGenerator(schema: schema);
      final code = generator.generate();

      expect(code, contains('PORT'));
      expect(code, contains('8080'));
    });

    test('generates code for encrypted fields', () {
      final schema = EnvSchema(
        fields: [
          const EnvField(
            name: 'API_KEY',
            type: 'String',
            encrypted: true,
            required: true,
          ),
        ],
      );

      final generator = EnvConfigGenerator(schema: schema);
      final code = generator.generate();

      expect(code, contains('API_KEY'));
      expect(code, contains('EncryptionService.decrypt'));
      expect(code, contains('_masterKey'));
    });

    test('generates code with master key', () {
      final schema = EnvSchema(
        fields: [
          const EnvField(
            name: 'TEST',
            type: 'String',
          ),
        ],
      );

      final generator = EnvConfigGenerator(
        schema: schema,
        masterKey: 'test-key',
      );
      final code = generator.generate();

      expect(code, contains("static const String _masterKey = 'test-key'"));
    });

    test('generates all field types', () {
      final schema = EnvSchema(
        fields: [
          const EnvField(name: 'STRING_VAR', type: 'String'),
          const EnvField(name: 'INT_VAR', type: 'int'),
          const EnvField(name: 'BOOL_VAR', type: 'bool'),
          const EnvField(name: 'DOUBLE_VAR', type: 'double'),
        ],
      );

      final generator = EnvConfigGenerator(schema: schema);
      final code = generator.generate();

      expect(code, contains('stringVar'));
      expect(code, contains('intVar'));
      expect(code, contains('boolVar'));
      expect(code, contains('doubleVar'));
    });
  });
}

