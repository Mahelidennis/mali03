/// API Configuration for Mali App
class ApiConfig {
  // OpenRouter API Configuration
  static const String openRouterApiKey = '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';
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  
  // OpenRouter Model Configuration
  static const String defaultModel = 'meta-llama/llama-3.1-8b-instruct:free';
  
  // Optional headers for OpenRouter leaderboards
  static const String siteUrl = 'https://mali-app.com';
  static const String siteName = 'Mali Financial Assistant';
  
  // API Headers
  static Map<String, String> get openRouterHeaders => {
    'Authorization': 'Bearer $openRouterApiKey',
    'HTTP-Referer': siteUrl,
    'X-Title': siteName,
    'Content-Type': 'application/json',
  };
}



