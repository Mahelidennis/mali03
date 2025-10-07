import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/hybrid_mali_service.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isTestingConnection = false;
  bool _connectionStatus = false;
  bool _preferOffline = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _preferOffline = prefs.getBool('prefer_offline_mode') ?? false; // Default to API mode
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prefer_offline_mode', _preferOffline);
    
    // Note: In a real app, you'd want to securely store the API key
    // For now, we'll just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved! API key should be updated in api_config.dart'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
    });

    try {
      final isConnected = await HybridMaliService.testApiConnection();
      setState(() {
        _connectionStatus = isConnected;
        _isTestingConnection = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isConnected ? 'API connection successful! 🎉' : 'API connection failed ❌'),
          backgroundColor: isConnected ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _connectionStatus = false;
        _isTestingConnection = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection test failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Settings'),
        backgroundColor: const Color(0xFFEE2B8D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Configuration Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Groq API Configuration (FREE)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Groq offers FREE AI responses with 14,400 requests per day!',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get your FREE API key at: https://console.groq.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFEE2B8D),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isTestingConnection ? null : _testConnection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _connectionStatus ? Colors.green : Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: _isTestingConnection
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Testing...'),
                                    ],
                                  )
                                : Text(_connectionStatus ? 'Connected ✅' : 'Test Connection'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Update groqApiKey in lib/config/api_config.dart'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEE2B8D),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Update Key'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Mode Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chat Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RadioListTile<bool>(
                      title: const Text('Offline Mode (Recommended)'),
                      subtitle: const Text('Always works, intelligent responses'),
                      value: true,
                      groupValue: _preferOffline,
                      onChanged: (value) {
                        setState(() {
                          _preferOffline = value ?? true;
                        });
                      },
                      activeColor: const Color(0xFFEE2B8D),
                    ),
                    RadioListTile<bool>(
                      title: const Text('API Mode'),
                      subtitle: const Text('Real AI responses (requires valid API key)'),
                      value: false,
                      groupValue: _preferOffline,
                      onChanged: (value) {
                        setState(() {
                          _preferOffline = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFFEE2B8D),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Information Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'How to Set Up FREE Groq API',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Go to https://console.groq.com (FREE)\n'
                      '2. Sign up with email or Google\n'
                      '3. Go to API Keys section\n'
                      '4. Create a new API key\n'
                      '5. Copy the key and update groqApiKey in lib/config/api_config.dart\n'
                      '6. Test the connection - you get 14,400 FREE requests per day!',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE2B8D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
