import 'env_field.dart';

/// Represents the complete environment schema configuration.
class EnvSchema {
  const EnvSchema({
    required this.fields,
    this.extensions = const {},
    this.masterKey,
  });

  /// List of environment variable field definitions.
  final List<EnvField> fields;

  /// Environment-specific overrides (e.g., 'dev', 'staging', 'prod').
  final Map<String, Map<String, dynamic>> extensions;

  /// Master key for encryption (optional, can be provided at runtime).
  final String? masterKey;

  /// Creates an EnvSchema from a YAML map.
  factory EnvSchema.fromMap(Map<String, dynamic> map) {
    final fields = <EnvField>[];
    if (map['fields'] != null) {
      final fieldsList = map['fields'] as List;
      for (final fieldMap in fieldsList) {
        fields.add(EnvField.fromMap(fieldMap as Map<String, dynamic>));
      }
    }

    final extensions = <String, Map<String, dynamic>>{};
    if (map['extensions'] != null) {
      final extensionsMap = map['extensions'] as Map<String, dynamic>;
      for (final entry in extensionsMap.entries) {
        extensions[entry.key] = entry.value as Map<String, dynamic>;
      }
    }

    return EnvSchema(
      fields: fields,
      extensions: extensions,
      masterKey: map['masterKey'] as String?,
    );
  }

  /// Validates the schema.
  void validate() {
    final fieldNames = <String>{};
    for (final field in fields) {
      if (fieldNames.contains(field.name)) {
        throw ArgumentError('Duplicate field name: ${field.name}');
      }
      fieldNames.add(field.name);

      // Validate type
      if (!['String', 'int', 'bool', 'double'].contains(field.type)) {
        throw ArgumentError(
          'Invalid type for field ${field.name}: ${field.type}',
        );
      }

      // Validate required fields have no default
      if (field.required && field.defaultValue != null) {
        throw ArgumentError(
          'Required field ${field.name} cannot have a default value',
        );
      }
    }
  }

  /// Gets a field by name.
  EnvField? getField(String name) {
    try {
      return fields.firstWhere((field) => field.name == name);
    } catch (e) {
      return null;
    }
  }
}


