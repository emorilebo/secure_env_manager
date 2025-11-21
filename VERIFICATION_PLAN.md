# Verification Plan

This document provides a comprehensive plan to verify that `secure_env_manager` is working correctly across all features.

## Overview

The verification plan covers:
1. Schema definition and parsing
2. Code generation
3. Encryption/decryption
4. Runtime access
5. Type safety
6. Required field validation
7. Default values
8. Environment extensions
9. Integration workflow

## Verification Steps

### Phase 1: Schema Definition

#### Test 1.1: Basic Schema Parsing
**Objective**: Verify YAML schema is correctly parsed into Dart objects.

**Steps**:
1. Create `env_schema.yaml` with basic fields:
   ```yaml
   fields:
     - name: API_URL
       type: String
       required: true
   ```

2. Run validation:
   ```bash
   dart run secure_env_manager validate
   ```

**Expected Result**: 
- ✅ Schema parses without errors
- ✅ Field count matches (1 field)
- ✅ Field properties are correct

**Verification Code**:
```dart
final schema = SchemaLoader.loadFromFile('env_schema.yaml');
expect(schema.fields.length, 1);
expect(schema.fields.first.name, 'API_URL');
expect(schema.fields.first.type, 'String');
expect(schema.fields.first.required, true);
```

#### Test 1.2: Schema Validation
**Objective**: Verify validation catches errors.

**Test Cases**:
- Duplicate field names → Should throw `ArgumentError`
- Invalid type → Should throw `ArgumentError`
- Required field with default → Should throw `ArgumentError`

**Verification**:
```dart
// Duplicate names
final schema = EnvSchema.fromMap({
  'fields': [
    {'name': 'DUPLICATE', 'type': 'String'},
    {'name': 'DUPLICATE', 'type': 'int'},
  ],
});
expect(() => schema.validate(), throwsArgumentError);
```

### Phase 2: Code Generation

#### Test 2.1: Generate EnvConfig Class
**Objective**: Verify code generation creates correct Dart class.

**Steps**:
1. Create schema with multiple field types
2. Run: `flutter pub run build_runner build`
3. Check generated file: `lib/env_config.g.dart`

**Expected Result**:
- ✅ File is generated
- ✅ Contains `class EnvConfig`
- ✅ Has getters for all fields
- ✅ Type-safe return types

**Verification**:
```dart
// Check file exists
expect(File('lib/env_config.g.dart').existsSync(), true);

// Check content
final content = File('lib/env_config.g.dart').readAsStringSync();
expect(content, contains('class EnvConfig'));
expect(content, contains('String get apiUrl'));
expect(content, contains('int get maxRetries'));
```

#### Test 2.2: Generated Code Compiles
**Objective**: Verify generated code compiles without errors.

**Steps**:
1. Generate code
2. Run: `flutter analyze`
3. Run: `flutter test`

**Expected Result**:
- ✅ No compilation errors
- ✅ No analysis errors
- ✅ Tests pass

### Phase 3: Encryption/Decryption

#### Test 3.1: Encrypt and Decrypt
**Objective**: Verify encryption/decryption works correctly.

**Steps**:
1. Encrypt a value:
   ```bash
   dart run secure_env_manager encrypt "secret-value" "master-key"
   ```

2. Decrypt the result:
   ```bash
   dart run secure_env_manager decrypt "<encrypted>" "master-key"
   ```

**Expected Result**:
- ✅ Encrypted value is different from original
- ✅ Decrypted value matches original
- ✅ Different encryptions of same value produce different outputs (due to IV)

**Verification Code**:
```dart
const value = 'my-secret';
const masterKey = 'master-key';

final encrypted = EncryptionService.encrypt(value, masterKey);
expect(encrypted, isNot(equals(value)));

final decrypted = EncryptionService.decrypt(encrypted, masterKey);
expect(decrypted, equals(value));
```

#### Test 3.2: Wrong Key Fails
**Objective**: Verify decryption fails with wrong key.

**Verification Code**:
```dart
const value = 'secret';
const correctKey = 'correct-key';
const wrongKey = 'wrong-key';

final encrypted = EncryptionService.encrypt(value, correctKey);
expect(
  () => EncryptionService.decrypt(encrypted, wrongKey),
  throwsException,
);
```

#### Test 3.3: IsEncrypted Detection
**Objective**: Verify encrypted value detection works.

**Verification Code**:
```dart
const value = 'plain-text';
const masterKey = 'key';

final encrypted = EncryptionService.encrypt(value, masterKey);
expect(EncryptionService.isEncrypted(encrypted), true);
expect(EncryptionService.isEncrypted(value), false);
```

### Phase 4: Runtime Access

#### Test 4.1: Access String Values
**Objective**: Verify string values are accessible.

**Steps**:
1. Set environment variable: `export API_URL="https://api.example.com"`
2. Access in code:
   ```dart
   final value = EnvConfig.getString('API_URL');
   expect(value, equals('https://api.example.com'));
   ```

**Expected Result**: ✅ Value is correctly retrieved

#### Test 4.2: Type-Safe Access
**Objective**: Verify type-safe access methods work.

**Test Cases**:
- `getInt()` → Returns `int?`
- `getBool()` → Returns `bool?`
- `getDouble()` → Returns `double?`
- `getString()` → Returns `String?`

**Verification Code**:
```dart
// Set values
Platform.environment['INT_VAR'] = '42';
Platform.environment['BOOL_VAR'] = 'true';
Platform.environment['DOUBLE_VAR'] = '3.14';

// Verify types
expect(EnvConfig.getInt('INT_VAR'), isA<int>());
expect(EnvConfig.getBool('BOOL_VAR'), isA<bool>());
expect(EnvConfig.getDouble('DOUBLE_VAR'), isA<double>());
```

#### Test 4.3: Default Values
**Objective**: Verify default values work when variable not set.

**Verification Code**:
```dart
final value = EnvConfig.getString('NONEXISTENT', defaultValue: 'default');
expect(value, equals('default'));
```

### Phase 5: Generated EnvConfig Usage

#### Test 5.1: Access Generated Fields
**Objective**: Verify generated EnvConfig class works.

**Steps**:
1. Generate code from schema
2. Set environment variables
3. Access via generated class:
   ```dart
   EnvConfig.setMasterKey('master-key');
   final apiUrl = EnvConfig.instance.apiUrl;
   ```

**Expected Result**:
- ✅ Generated getters work
- ✅ Type-safe access
- ✅ Required fields throw if missing

#### Test 5.2: Encrypted Field Decryption
**Objective**: Verify encrypted fields are automatically decrypted.

**Steps**:
1. Encrypt a value
2. Set as environment variable
3. Access via generated getter

**Verification Code**:
```dart
// Encrypt and set
final encrypted = EncryptionService.encrypt('secret', 'master-key');
Platform.environment['API_KEY'] = encrypted;

// Access via generated code
EnvConfig.setMasterKey('master-key');
final decrypted = EnvConfig.instance.apiKey;
expect(decrypted, equals('secret'));
```

### Phase 6: Required Field Validation

#### Test 6.1: Required Field Error
**Objective**: Verify required fields throw when missing.

**Verification Code**:
```dart
// Don't set required field
Platform.environment.remove('REQUIRED_FIELD');

// Access should throw
expect(
  () => EnvConfig.instance.requiredField,
  throwsStateError,
);
```

### Phase 7: Environment Extensions

#### Test 7.1: Extension Overrides
**Objective**: Verify environment extensions work.

**Steps**:
1. Define extensions in schema
2. Apply extension at build time
3. Verify overridden values are used

**Note**: Extensions are typically applied during code generation or build process.

### Phase 8: Integration Test

#### Test 8.1: Full Workflow
**Objective**: Verify complete workflow from schema to runtime.

**Steps**:
1. ✅ Create `env_schema.yaml` with fields
2. ✅ Validate schema: `dart run secure_env_manager validate`
3. ✅ Encrypt secret values: `dart run secure_env_manager encrypt ...`
4. ✅ Generate code: `flutter pub run build_runner build`
5. ✅ Set environment variables
6. ✅ Use generated EnvConfig in app
7. ✅ Verify all values accessible and correct

**Expected Result**: Complete workflow works end-to-end

## Automated Verification Script

Create a script to run all verifications:

```bash
#!/bin/bash
# verify.sh

echo "=== Verification Plan ==="

echo "1. Schema Validation..."
dart run secure_env_manager validate || exit 1

echo "2. Running Tests..."
flutter test || exit 1

echo "3. Code Generation..."
flutter pub run build_runner build --delete-conflicting-outputs || exit 1

echo "4. Analyzing Generated Code..."
flutter analyze || exit 1

echo "5. Encryption Test..."
ENCRYPTED=$(dart run secure_env_manager encrypt "test-value" "test-key")
DECRYPTED=$(dart run secure_env_manager decrypt "$ENCRYPTED" "test-key")
if [ "$DECRYPTED" != "test-value" ]; then
  echo "Encryption test failed"
  exit 1
fi

echo "✅ All verifications passed!"
```

## Success Criteria

All of the following must pass:

- [x] Schema parsing works correctly
- [x] Schema validation catches errors
- [x] Code generation creates valid Dart code
- [x] Generated code compiles without errors
- [x] Encryption produces different outputs
- [x] Decryption recovers original values
- [x] Wrong key fails decryption
- [x] Runtime access works for all types
- [x] Default values work
- [x] Required fields throw when missing
- [x] Encrypted fields decrypt automatically
- [x] Full integration workflow works

## Conclusion

Once all verification steps pass, the package is confirmed to be working correctly and ready for production use.


