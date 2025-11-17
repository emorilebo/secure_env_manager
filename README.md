# 🔐 Secure Env Manager

[![pub package](https://img.shields.io/pub/v/secure_env_manager.svg)](https://pub.dev/packages/secure_env_manager)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/emorilebo/secure_env_manager/actions/workflows/ci.yml/badge.svg)](https://github.com/emorilebo/secure_env_manager/actions/workflows/ci.yml)

> **Type-safe environment variable management with code generation, encryption support, and runtime access**

Manage your app's environment variables securely with automatic code generation, encryption for secrets, and type-safe access. Perfect for Flutter and Dart applications that need to handle sensitive configuration data.

## ✨ What Makes This Package Special?

This isn't just another environment variable loader. We've built a complete solution that combines:

- **📝 YAML Schema Definition**: Define all environment variables in a single, version-controlled schema file
- **🔧 Code Generation**: Automatically generate strongly-typed Dart classes using `build_runner`
- **🔒 Encryption Support**: Encrypt sensitive values (API keys, tokens) with AES encryption
- **✅ Type Safety**: Compile-time validation and type-safe access to all variables
- **🌍 Environment Extensions**: Override values per environment (dev, staging, prod)
- **⚡ Runtime Access**: Simple API to access config values with automatic decryption
- **🛠️ CLI Tools**: Command-line utilities for encryption, validation, and code generation

Perfect for production apps that need secure handling of API keys, database credentials, feature flags, and other sensitive configuration.

## 🚀 Quick Start

### Installation

Add `secure_env_manager` to your `pubspec.yaml`:

```yaml
dependencies:
  secure_env_manager: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.8
```

Then run:

```bash
flutter pub get
```

### 1. Define Your Schema

Create an `env_schema.yaml` file in your project root:

```yaml
fields:
  - name: API_URL
    type: String
    required: true
    description: "Base URL for the API"

  - name: API_KEY
    type: String
    required: true
    encrypted: true
    description: "API key (encrypted)"

  - name: FEATURE_FLAG
    type: bool
    required: false
    defaultValue: false
    description: "Enable new feature"

  - name: MAX_RETRIES
    type: int
    required: false
    defaultValue: 3
    description: "Maximum retry attempts"

extensions:
  dev:
    API_URL: "https://api-dev.example.com"
    FEATURE_FLAG: true
  prod:
    API_URL: "https://api.example.com"
    FEATURE_FLAG: false
```

### 2. Generate Code

Run the code generator:

```bash
flutter pub run build_runner build
```

This generates a strongly-typed `EnvConfig` class in `lib/env_config.g.dart`.

### 3. Use in Your App

```dart
import 'package:secure_env_manager/secure_env_manager.dart';
import 'env_config.g.dart'; // Generated file

void main() {
  // Set master key for decryption (get from secure storage in production)
  EnvConfig.setMasterKey('your-master-key');
  
  // Access variables with type safety
  final apiUrl = EnvConfig.instance.apiUrl; // String
  final apiKey = EnvConfig.instance.apiKey; // String (decrypted)
  final featureFlag = EnvConfig.instance.featureFlag; // bool
  final maxRetries = EnvConfig.instance.maxRetries; // int
}
```

## 📚 Features in Detail

### Schema Definition

Define all your environment variables in a YAML schema:

```yaml
fields:
  - name: DATABASE_URL
    type: String
    required: true
    pattern: "^https?://.*"  # Optional regex validation
    includeInEnv: true       # Include in generated .env file

  - name: SECRET_TOKEN
    type: String
    encrypted: true          # Encrypt this value
    required: true
```

**Supported Types:**
- `String` - Text values
- `int` - Integer numbers
- `bool` - Boolean values
- `double` - Floating-point numbers

### Encryption

Encrypt sensitive values using the CLI:

```bash
# Encrypt a value
dart run secure_env_manager encrypt "my-secret-key" "master-key"

# The output can be used in your .env file
```

Or programmatically:

```dart
import 'package:secure_env_manager/secure_env_manager.dart';

final encrypted = EncryptionService.encrypt('my-secret', 'master-key');
final decrypted = EncryptionService.decrypt(encrypted, 'master-key');
```

### Environment Extensions

Override values per environment:

```yaml
extensions:
  dev:
    API_URL: "http://localhost:3000"
    DEBUG_MODE: true
  staging:
    API_URL: "https://staging-api.example.com"
  prod:
    API_URL: "https://api.example.com"
    DEBUG_MODE: false
```

### Code Generation

The generated `EnvConfig` class provides:

- **Type-safe getters** for each field
- **Automatic validation** of required fields
- **Runtime decryption** of encrypted values
- **Default value support** for optional fields

```dart
// Generated code example
class EnvConfig {
  String get apiUrl {
    final value = Platform.environment['API_URL'];
    if (value == null) {
      throw StateError('Required environment variable API_URL is not set');
    }
    return value;
  }
  
  String get apiKey {
    final value = Platform.environment['API_KEY'];
    if (value == null) {
      throw StateError('Required environment variable API_KEY is not set');
    }
    if (_masterKey == null) {
      throw StateError('Master key not set');
    }
    return EncryptionService.decrypt(value, _masterKey!);
  }
}
```

## 🛠️ CLI Commands

The package includes a CLI tool for common operations:

```bash
# Validate schema
dart run secure_env_manager validate

# Generate config (or use build_runner)
dart run secure_env_manager generate

# Encrypt a value
dart run secure_env_manager encrypt "value" "master-key"

# Decrypt a value
dart run secure_env_manager decrypt "encrypted-value" "master-key"
```

## 💡 Real-World Examples

### Storing API Credentials

```dart
// 1. Define in schema
// - name: API_KEY
//   type: String
//   encrypted: true
//   required: true

// 2. Encrypt the value
// dart run secure_env_manager encrypt "actual-api-key" "master-key"

// 3. Add to .env file
// API_KEY=<encrypted-value>

// 4. Use in app
void main() {
  EnvConfig.setMasterKey('master-key-from-secure-storage');
  final apiKey = EnvConfig.instance.apiKey; // Automatically decrypted
}
```

### Feature Flags

```yaml
fields:
  - name: ENABLE_NEW_UI
    type: bool
    defaultValue: false
  - name: MAX_CACHE_SIZE
    type: int
    defaultValue: 100
```

```dart
if (EnvConfig.instance.enableNewUi) {
  // Show new UI
}

final cacheSize = EnvConfig.instance.maxCacheSize;
```

### Database Configuration

```yaml
fields:
  - name: DB_HOST
    type: String
    required: true
  - name: DB_PORT
    type: int
    defaultValue: 5432
  - name: DB_PASSWORD
    type: String
    encrypted: true
    required: true
```

## ⚠️ Security Considerations

### Master Key Management

**⚠️ Important**: The master key should never be committed to version control.

**Best Practices:**
1. Store master key in secure storage (Keychain, Keystore, or environment variable)
2. Use different keys for different environments
3. Rotate keys periodically
4. Never log or expose encrypted values

```dart
// Good: Get from secure storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
final masterKey = await storage.read(key: 'env_master_key');
EnvConfig.setMasterKey(masterKey!);

// Bad: Hardcoded key
EnvConfig.setMasterKey('hardcoded-key-123'); // ❌
```

### Encrypted Values in Binary

**⚠️ Warning**: Encrypted values stored in your app's binary can potentially be extracted by reverse engineering. For maximum security:

- Use server-side configuration for highly sensitive secrets
- Consider using a secrets management service (AWS Secrets Manager, HashiCorp Vault)
- Use this package for development and less-sensitive production configs

## 🧪 Testing

Run tests with:

```bash
flutter test
```

The package includes comprehensive tests for:
- Schema parsing and validation
- Encryption/decryption
- Code generation
- Runtime access API

## 🐛 Troubleshooting

### "Required environment variable is not set"

Ensure the variable is set in your environment or `.env` file:

```bash
export API_URL="https://api.example.com"
```

### "Master key not set"

Call `EnvConfig.setMasterKey()` before accessing encrypted values:

```dart
EnvConfig.setMasterKey('your-master-key');
```

### Code generation fails

1. Ensure `env_schema.yaml` exists in project root
2. Check schema syntax is valid YAML
3. Run `dart run secure_env_manager validate` to check schema

### Decryption fails

- Verify the master key matches the one used for encryption
- Ensure the encrypted value wasn't corrupted
- Check that the value is actually encrypted (use `EncryptionService.isEncrypted()`)

## 📱 Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅ Full support |
| iOS      | ✅ Full support |
| Web      | ✅ Full support |
| macOS    | ✅ Full support |
| Windows  | ✅ Full support |
| Linux    | ✅ Full support |

## 👨‍💻 Author

**Godfrey Lebo** - Fullstack Developer & Technical PM

> With **9+ years of industry experience**, I specialize in building AI-powered applications, scalable mobile solutions, and secure backend systems. I've led teams delivering marketplaces, fintech platforms, and AI applications serving thousands of users.

- 📧 **Email**: [emorylebo@gmail.com](mailto:emorylebo@gmail.com)
- 💼 **LinkedIn**: [godfreylebo](https://www.linkedin.com/in/godfreylebo/)
- 🌐 **Portfolio**: [godfreylebo.dev](https://www.godfreylebo.dev/)
- 🐙 **GitHub**: [@emorilebo](https://github.com/emorilebo)

## 🤝 Contributing

We welcome contributions! Whether you're fixing bugs, adding features, or improving documentation, your help makes this package better for everyone.

**Ways to contribute:**
- 🐛 Report bugs
- 💡 Suggest new features
- 📝 Improve documentation
- 🔧 Submit pull requests

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Additional Resources

- [CHANGELOG.md](CHANGELOG.md) - Version history and updates
- [VALIDATION.md](VALIDATION.md) - Verification and testing guide
- [GitHub Repository](https://github.com/emorilebo/secure_env_manager) - Source code and issues

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Build runner and code generation tools
- Community contributors and users

---

**Made with ❤️ by [Godfrey Lebo](https://www.godfreylebo.dev/)**

If this package helps secure your app's configuration, consider giving it a ⭐ on GitHub!

