/// API Configuration for Mali App
class ApiConfig {
  // Groq API Configuration (Free Tier - 14,400 requests/day)
  static const String groqApiKey = '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';
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  
  // Groq Model Configuration (Fast and free)
  static const String defaultModel = 'llama3-8b-8192'; // Fast and capable model
  static const String alternativeModel = 'mixtral-8x7b-32768'; // Alternative option
  
  // App Information
  static const String appName = 'Mali Financial Assistant';
  static const String appVersion = '1.0.0';
  
  // API Headers for Groq
  static Map<String, String> get groqHeaders => {
    'Authorization': 'Bearer $groqApiKey',
    'Content-Type': 'application/json',
  };
  
  // Check if Groq API key is configured
  static bool get isGroqConfigured => 
      groqApiKey.isNotEmpty && 
      !groqApiKey.contains('YOUR_') &&
      groqApiKey.length > 20;
}



