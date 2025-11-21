/// Secure Environment Manager for Flutter/Dart
/// 
/// Provides type-safe environment variable management with:
/// - YAML schema definition
/// - Code generation via build_runner
/// - Encryption support for secrets
/// - Runtime access API
library secure_env_manager;

export 'src/runtime/env_config.dart';
export 'src/encryption/encryption_service.dart';
export 'src/schema/env_schema.dart';
export 'src/schema/env_field.dart';
export 'src/schema/schema_loader.dart';


