import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'env_schema.dart';

/// Loads and parses environment schema from YAML files.
class SchemaLoader {
  /// Loads schema from a YAML file.
  static EnvSchema loadFromFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('Schema file not found: $filePath');
    }

    final content = file.readAsStringSync();
    return loadFromString(content);
  }

  /// Loads schema from a YAML string.
  static EnvSchema loadFromString(String yamlContent) {
    try {
      final yaml = loadYaml(yamlContent) as Map<String, dynamic>;
      return EnvSchema.fromMap(yaml);
    } catch (e) {
      throw FormatException('Failed to parse YAML schema: $e');
    }
  }

  /// Finds and loads schema file from common locations.
  static EnvSchema loadFromProject() {
    final possiblePaths = [
      'env_schema.yaml',
      'env_schema.yml',
      'config/env_schema.yaml',
      'lib/env_schema.yaml',
    ];

    for (final possiblePath in possiblePaths) {
      final file = File(possiblePath);
      if (file.existsSync()) {
        return loadFromFile(possiblePath);
      }
    }

    throw FileSystemException(
      'Schema file not found. Tried: ${possiblePaths.join(", ")}',
    );
  }
}

