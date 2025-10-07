import 'package:flutter/material.dart';
import 'services/groq_service_web.dart';
import 'config/api_config.dart';

class TestGroqConnection extends StatefulWidget {
  const TestGroqConnection({super.key});

  @override
  State<TestGroqConnection> createState() => _TestGroqConnectionState();
}

class _TestGroqConnectionState extends State<TestGroqConnection> {
  String _status = 'Initializing...';
  String _response = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _status = 'Testing Groq API connection...';
      _isLoading = true;
    });

    try {
      // Check if API is configured
      if (!ApiConfig.isGroqConfigured) {
        setState(() {
          _status = '❌ API Key not configured';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _status = '✅ API Key configured\n🔄 Testing connection...';
      });

      // Test connection
      final connected = await GroqServiceWeb.testConnection();
      
      if (connected) {
        setState(() {
          _status = '✅ API Key configured\n✅ Connection successful\n🔄 Testing chat...';
        });

        // Test actual chat
        final response = await GroqServiceWeb.sendChatMessage(
          userMessage: 'Hello! Can you respond with just "Hi there!" to confirm you\'re working?',
          systemPrompt: 'You are a helpful assistant. Keep responses very brief.',
        );

        setState(() {
          _status = '✅ API Key configured\n✅ Connection successful\n✅ Chat working!';
          _response = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _status = '✅ API Key configured\n❌ Connection failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        title: const Text('Test Groq API'),
        backgroundColor: const Color(0xFFEE2B8D),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE2B8D)),
                ),
              const SizedBox(height: 24),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              if (_response.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Response:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEE2B8D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _response,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE2B8D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Test Again'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

