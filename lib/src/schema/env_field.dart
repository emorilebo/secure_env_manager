/// Represents a single environment variable field definition.
class EnvField {
  const EnvField({
    required this.name,
    required this.type,
    this.defaultValue,
    this.required = false,
    this.pattern,
    this.includeInEnv = true,
    this.encrypted = false,
    this.description,
  });

  /// Name of the environment variable.
  final String name;

  /// Type of the variable (String, int, bool, double).
  final String type;

  /// Default value if not provided.
  final dynamic defaultValue;

  /// Whether this field is required.
  final bool required;

  /// Optional regex pattern for validation.
  final String? pattern;

  /// Whether to include in generated .env file.
  final bool includeInEnv;

  /// Whether this value should be encrypted.
  final bool encrypted;

  /// Description of the field.
  final String? description;

  /// Creates an EnvField from a map (typically from YAML).
  factory EnvField.fromMap(Map<String, dynamic> map) {
    return EnvField(
      name: map['name'] as String,
      type: map['type'] as String? ?? 'String',
      defaultValue: map['default'],
      required: map['required'] as bool? ?? false,
      pattern: map['pattern'] as String?,
      includeInEnv: map['includeInEnv'] as bool? ?? true,
      encrypted: map['encrypted'] as bool? ?? false,
      description: map['description'] as String?,
    );
  }

  /// Converts to a map (for YAML serialization).
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      if (defaultValue != null) 'default': defaultValue,
      'required': required,
      if (pattern != null) 'pattern': pattern,
      'includeInEnv': includeInEnv,
      'encrypted': encrypted,
      if (description != null) 'description': description,
    };
  }
}


