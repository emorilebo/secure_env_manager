# Validation Guide

This document describes how to verify that `secure_env_manager` is working correctly.

## Prerequisites

1. Flutter SDK installed (>=3.3.0)
2. Dart SDK (>=3.0.0)
3. A device or emulator for testing

## Setup

1. Navigate to the package directory:
   ```bash
   cd secure_env_manager
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Navigate to the example directory:
   ```bash
   cd example
   flutter pub get
   ```

## Validation Steps

### 1. Schema Validation

**Test**: Verify schema parsing and validation works.

**Steps**:
1. Create a test schema file:
   ```bash
   echo "fields:
  - name: TEST_VAR
    type: String
    required: true" > test_schema.yaml
   ```

2. Validate the schema:
   ```bash
   dart run bin/secure_env_manager.dart validate
   ```

**Expected Result**: Schema validates successfully.

### 2. Encryption/Decryption

**Test**: Verify encryption and decryption work correctly.

**Steps**:
1. Encrypt a value:
   ```bash
   dart run bin/secure_env_manager.dart encrypt "my-secret" "master-key"
   ```

2. Copy the encrypted output and decrypt it:
   ```bash
   dart run bin/secure_env_manager.dart decrypt "<encrypted-output>" "master-key"
   ```

**Expected Result**: Decrypted value matches original "my-secret".

### 3. Code Generation

**Test**: Verify code generation creates EnvConfig class.

**Steps**:
1. Ensure `env_schema.yaml` exists in project root
2. Run code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Check that `lib/env_config.g.dart` was generated
4. Verify the generated code contains your fields

**Expected Result**: `env_config.g.dart` file is generated with correct field getters.

### 4. Runtime Access

**Test**: Verify runtime access to environment variables.

**Steps**:
1. Set environment variables:
   ```bash
   export API_URL="https://api.example.com"
   export API_KEY="test-key"
   ```

2. In your Dart code:
   ```dart
   import 'package:secure_env_manager/secure_env_manager.dart';
   
   void main() {
     final apiUrl = EnvConfig.getString('API_URL');
     print(apiUrl); // Should print: https://api.example.com
   }
   ```

**Expected Result**: Values are correctly retrieved from environment.

### 5. Encrypted Values

**Test**: Verify encrypted values are decrypted at runtime.

**Steps**:
1. Encrypt a value:
   ```bash
   dart run bin/secure_env_manager.dart encrypt "secret-value" "master-key"
   ```

2. Set the encrypted value as environment variable:
   ```bash
   export ENCRYPTED_VAR="<encrypted-output>"
   ```

3. In your code:
   ```dart
   EnvConfig.setMasterKey('master-key');
   final decrypted = EnvConfig.getString('ENCRYPTED_VAR');
   print(decrypted); // Should print: secret-value
   ```

**Expected Result**: Encrypted value is correctly decrypted.

### 6. Type Safety

**Test**: Verify type-safe access works.

**Steps**:
1. Set values with correct types:
   ```bash
   export INT_VAR="42"
   export BOOL_VAR="true"
   export DOUBLE_VAR="3.14"
   ```

2. Access with type-safe methods:
   ```dart
   final intValue = EnvConfig.getInt('INT_VAR'); // int
   final boolValue = EnvConfig.getBool('BOOL_VAR'); // bool
   final doubleValue = EnvConfig.getDouble('DOUBLE_VAR'); // double
   ```

**Expected Result**: Values are correctly parsed to their types.

### 7. Required Fields

**Test**: Verify required fields throw errors when missing.

**Steps**:
1. Define a required field in schema
2. Don't set it in environment
3. Try to access it

**Expected Result**: Appropriate error is thrown.

### 8. Default Values

**Test**: Verify default values work.

**Steps**:
1. Define a field with default value in schema
2. Don't set it in environment
3. Access it

**Expected Result**: Default value is returned.

### 9. Integration Test

**Test**: Full workflow from schema to runtime.

**Steps**:
1. Create `env_schema.yaml` with fields
2. Run code generation
3. Set environment variables
4. Use generated EnvConfig class
5. Verify all values are accessible

**Expected Result**: Complete workflow works end-to-end.

## Common Issues

### Issue: Schema not found
**Solution**: Ensure `env_schema.yaml` is in project root.

### Issue: Code generation fails
**Solution**: Check schema syntax, run `dart run secure_env_manager validate`.

### Issue: Decryption fails
**Solution**: Verify master key matches encryption key.

### Issue: Required field error
**Solution**: Set the environment variable or provide default value.

## Performance Benchmarks

Expected performance characteristics:
- **Schema Loading**: <10ms for typical schemas
- **Encryption**: <5ms per value
- **Decryption**: <5ms per value
- **Code Generation**: <1s for typical schemas

## Conclusion

If all validation steps pass, the package is working correctly and ready for use. For issues or questions, please refer to the README or open an issue on GitHub.


