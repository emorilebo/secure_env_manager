import 'package:flutter_test/flutter_test.dart';
import 'package:secure_env_manager/secure_env_manager.dart';

void main() {
  group('EnvField', () {
    test('creates field from map', () {
      final field = EnvField.fromMap({
        'name': 'API_URL',
        'type': 'String',
        'required': true,
        'description': 'API endpoint',
      });

      expect(field.name, 'API_URL');
      expect(field.type, 'String');
      expect(field.required, true);
      expect(field.description, 'API endpoint');
      expect(field.encrypted, false);
    });

    test('creates encrypted field', () {
      final field = EnvField.fromMap({
        'name': 'API_KEY',
        'type': 'String',
        'encrypted': true,
      });

      expect(field.encrypted, true);
    });

    test('converts to map', () {
      const field = EnvField(
        name: 'TEST',
        type: 'int',
        defaultValue: 42,
        required: false,
      );

      final map = field.toMap();
      expect(map['name'], 'TEST');
      expect(map['type'], 'int');
      expect(map['default'], 42);
      expect(map['required'], false);
    });
  });

  group('EnvSchema', () {
    test('creates schema from map', () {
      final schema = EnvSchema.fromMap({
        'fields': [
          {
            'name': 'API_URL',
            'type': 'String',
            'required': true,
          },
          {
            'name': 'PORT',
            'type': 'int',
            'defaultValue': 8080,
          },
        ],
        'extensions': {
          'dev': {
            'API_URL': 'http://localhost',
          },
        },
      });

      expect(schema.fields.length, 2);
      expect(schema.extensions.length, 1);
      expect(schema.getField('API_URL')?.name, 'API_URL');
      expect(schema.getField('NONEXISTENT'), null);
    });

    test('validates schema successfully', () {
      final schema = EnvSchema.fromMap({
        'fields': [
          {
            'name': 'API_URL',
            'type': 'String',
            'required': true,
          },
        ],
      });

      expect(() => schema.validate(), returnsNormally);
    });

    test('validates duplicate field names', () {
      final schema = EnvSchema.fromMap({
        'fields': [
          {
            'name': 'DUPLICATE',
            'type': 'String',
          },
          {
            'name': 'DUPLICATE',
            'type': 'int',
          },
        ],
      });

      expect(() => schema.validate(), throwsArgumentError);
    });

    test('validates invalid type', () {
      final schema = EnvSchema.fromMap({
        'fields': [
          {
            'name': 'INVALID',
            'type': 'InvalidType',
          },
        ],
      });

      expect(() => schema.validate(), throwsArgumentError);
    });

    test('validates required field with default', () {
      final schema = EnvSchema.fromMap({
        'fields': [
          {
            'name': 'REQUIRED',
            'type': 'String',
            'required': true,
            'default': 'value',
          },
        ],
      });

      expect(() => schema.validate(), throwsArgumentError);
    });
  });

  group('SchemaLoader', () {
    test('loads schema from string', () {
      const yamlContent = '''
fields:
  - name: API_URL
    type: String
    required: true
''';

      final schema = SchemaLoader.loadFromString(yamlContent);
      expect(schema.fields.length, 1);
      expect(schema.fields.first.name, 'API_URL');
    });

    test('throws on invalid YAML', () {
      const invalidYaml = 'invalid: yaml: content: [';

      expect(
        () => SchemaLoader.loadFromString(invalidYaml),
        throwsFormatException,
      );
    });
  });
}

