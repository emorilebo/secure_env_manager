import 'package:flutter/material.dart';
import 'package:secure_env_manager/secure_env_manager.dart';

void main() {
  // Set master key for decryption (in production, get this securely)
  // For demo purposes, we're using a hardcoded key
  // In real apps, get this from secure storage or keychain
  EnvConfig.setMasterKey('demo-master-key-12345');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Env Manager Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const EnvConfigScreen(),
    );
  }
}

class EnvConfigScreen extends StatefulWidget {
  const EnvConfigScreen({super.key});

  @override
  State<EnvConfigScreen> createState() => _EnvConfigScreenState();
}

class _EnvConfigScreenState extends State<EnvConfigScreen> {
  Map<String, String>? _configValues;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() {
    try {
      // Access environment variables using the generated EnvConfig
      // Note: In a real app, these would be generated from env_schema.yaml
      // For this example, we're using the runtime API
      final values = <String, String>{};

      // Try to get values (these would come from generated code in real usage)
      final apiUrl = EnvConfig.getString('API_URL');
      final apiKey = EnvConfig.getString('API_KEY');
      final featureFlag = EnvConfig.getBool('FEATURE_FLAG');
      final maxRetries = EnvConfig.getInt('MAX_RETRIES');
      final timeout = EnvConfig.getDouble('TIMEOUT_SECONDS');

      if (apiUrl != null) values['API_URL'] = apiUrl;
      if (apiKey != null) values['API_KEY'] = '***${apiKey.substring(apiKey.length - 4)}';
      if (featureFlag != null) values['FEATURE_FLAG'] = featureFlag.toString();
      if (maxRetries != null) values['MAX_RETRIES'] = maxRetries.toString();
      if (timeout != null) values['TIMEOUT_SECONDS'] = timeout.toString();

      setState(() {
        _configValues = values;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading config: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Env Manager Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadConfig,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _configValues == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      const Text(
                        'Environment Configuration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._configValues!.entries.map((entry) => Card(
                            child: ListTile(
                              title: Text(entry.key),
                              subtitle: Text(entry.value),
                              leading: const Icon(Icons.settings),
                            ),
                          ),),
                      const SizedBox(height: 24),
                      const Card(
                        color: Colors.blue,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How it works:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '1. Define variables in env_schema.yaml',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '2. Run: flutter pub run build_runner build',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '3. Access via generated EnvConfig class',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '4. Encrypted values are decrypted at runtime',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}


