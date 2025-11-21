import 'dart:async';
import 'package:build/build.dart';
import 'env_config_generator.dart';
import '../schema/schema_loader.dart';

/// Build runner builder for generating EnvConfig class.
class EnvConfigBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['env_config.g.dart'],
  };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // Look for env_schema.yaml in the project root
    const schemaPath = 'env_schema.yaml';
    
    try {
      // Try to read schema from asset or file
      final schemaContent = await _readSchema(buildStep, schemaPath);
      if (schemaContent == null) {
        log.warning('env_schema.yaml not found. Skipping EnvConfig generation.');
        return;
      }

      final schema = SchemaLoader.loadFromString(schemaContent);
      schema.validate();

      // Extract master key from schema or environment
      final masterKey = schema.masterKey ?? 
        const String.fromEnvironment('ENV_MASTER_KEY');

      final generator = EnvConfigGenerator(
        schema: schema,
        masterKey: masterKey.isEmpty ? null : masterKey,
      );

      final generatedCode = generator.generate();
      
      // Write to output
      final outputId = buildStep.allowedOutputs.single;
      await buildStep.writeAsString(outputId, generatedCode);
      
      log.info('Generated EnvConfig class with ${schema.fields.length} fields');
    } catch (e, stackTrace) {
      log.severe('Failed to generate EnvConfig: $e', e, stackTrace);
      rethrow;
    }
  }

  Future<String?> _readSchema(BuildStep buildStep, String schemaPath) async {
    // Try to read as asset first
    try {
      final assetId = AssetId.resolve(Uri.parse(schemaPath));
      return await buildStep.readAsString(assetId);
    } catch (e) {
      // Try reading from file system
      try {
        final file = buildStep.inputId.uri.resolve(schemaPath).toFilePath();
        return await buildStep.readAsString(AssetId.resolve(Uri.file(file)));
      } catch (e2) {
        return null;
      }
    }
  }
}

Builder envConfigBuilder(BuilderOptions options) => EnvConfigBuilder();

