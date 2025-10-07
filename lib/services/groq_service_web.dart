import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Groq API Service for Mali Chat (Web-optimized with CORS handling)
class GroqServiceWeb {
  
  /// Send a chat message and get AI response from Groq
  static Future<String> sendChatMessage({
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
    String? systemPrompt,
  }) async {
    try {
      // Build messages array
      final messages = <Map<String, String>>[];
      
      // Add system prompt if provided
      if (systemPrompt != null) {
        messages.add({
          'role': 'system',
          'content': systemPrompt,
        });
      }
      
      // Add conversation history
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }
      
      // Add current user message
      messages.add({
        'role': 'user',
        'content': userMessage,
      });
      
      print('🚀 Sending request to Groq with model: ${ApiConfig.defaultModel}');
      print('📝 Messages count: ${messages.length}');
      
      final requestBody = {
        'model': ApiConfig.defaultModel,
        'messages': messages,
        'max_tokens': 1024,
        'temperature': 0.7,
        'top_p': 1,
        'stream': false,
      };
      
      print('📦 Request payload: ${jsonEncode(requestBody)}');
      
      // Make API request with timeout and proper headers
      final response = await http.post(
        Uri.parse('${ApiConfig.groqBaseUrl}/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${ApiConfig.groqApiKey}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout after 30 seconds');
        },
      );
      
      print('✅ Groq response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📨 Response data: $data');
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final aiResponse = data['choices'][0]['message']['content'] as String;
          print('💬 AI Response: $aiResponse');
          return aiResponse;
        } else {
          print('❌ No choices in API response: ${response.body}');
          throw Exception('No choices in API response');
        }
      } else if (response.statusCode == 401) {
        print('❌ Authentication error: Invalid API key');
        throw Exception('Invalid Groq API key');
      } else if (response.statusCode == 429) {
        print('❌ Rate limit exceeded');
        throw Exception('Groq API rate limit exceeded');
      } else {
        print('❌ Groq API error: ${response.statusCode}');
        print('📄 Error body: ${response.body}');
        throw Exception('Groq API error: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network error: Unable to reach Groq API. Check your internet connection.');
    } catch (e) {
      print('❌ Groq API error: $e');
      rethrow;
    }
  }
  
  /// Get Mali's financial coaching response using Groq
  static Future<String> getMaliCoachingResponse({
    required String userMessage,
    required Map<String, dynamic> financialContext,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final systemPrompt = '''
You are Mali, a sassy and supportive financial big sister for young women in Kenya. You help them make smart money decisions with practical financial knowledge and a friendly, empowering tone.

Your personality traits:
- Supportive and encouraging, but also direct when needed
- Financially savvy with practical, actionable advice specific to Kenya
- Empathetic but won't let users make excuses
- Celebrates wins and provides tough love when necessary
- Always maintain context from previous conversation
- Ask follow-up questions to better understand user needs
- Understand M-PESA, mobile money, and Kenyan financial systems

User's current financial context:
- Total Expenses: KES ${financialContext['totalExpenses']?.toStringAsFixed(0) ?? '0'}
- Total Income: KES ${financialContext['totalIncome']?.toStringAsFixed(0) ?? '0'}
- Active Goals: ${financialContext['activeGoals'] ?? 0}
- Budget Status: ${financialContext['budgetStatus'] ?? 'Unknown'}

Guidelines:
- Keep responses conversational, practical, and under 200 words
- Use emojis sparingly but effectively (2-3 max per response)
- Reference the user's financial data when relevant
- Provide actionable next steps specific to Kenya
- If user is overspending, be supportive but firm
- If user is doing well, celebrate their progress
- Always maintain the conversation flow and context
- Speak only in English
- Be specific about amounts in KES when relevant
- Understand M-PESA transactions and mobile banking

Remember: You're having a real conversation, not just answering individual questions. Build on previous messages and maintain continuity. You're their financial big sister - be encouraging but honest about their situation.
''';
    
    return await sendChatMessage(
      userMessage: userMessage,
      systemPrompt: systemPrompt,
      conversationHistory: conversationHistory,
    );
  }
  
  /// Test Groq API connection
  static Future<bool> testConnection() async {
    if (!ApiConfig.isGroqConfigured) {
      print('❌ Groq API key not configured');
      return false;
    }
    
    try {
      print('🧪 Testing Groq API connection...');
      final response = await http.post(
        Uri.parse('${ApiConfig.groqBaseUrl}/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${ApiConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': ApiConfig.defaultModel,
          'messages': [
            {'role': 'user', 'content': 'Hello'}
          ],
          'max_tokens': 10,
        }),
      ).timeout(const Duration(seconds: 10));
      
      print('✅ Groq test response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ Groq API connection successful!');
        return true;
      } else {
        print('❌ Groq test failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Groq connection test failed: $e');
      return false;
    }
  }
  
  /// Get available models from Groq
  static Future<List<String>> getAvailableModels() async {
    try {
      print('🔍 Fetching available Groq models...');
      final response = await http.get(
        Uri.parse('${ApiConfig.groqBaseUrl}/models'),
        headers: {
          'Authorization': 'Bearer ${ApiConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = (data['data'] as List)
            .map((model) => model['id'] as String)
            .where((id) => id.contains('llama') || id.contains('mixtral'))
            .toList();
        print('✅ Found ${models.length} models: $models');
        return models;
      }
    } catch (e) {
      print('❌ Failed to get Groq models: $e');
    }
    
    return [ApiConfig.defaultModel, ApiConfig.alternativeModel];
  }
}

