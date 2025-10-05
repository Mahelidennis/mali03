import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Groq API Service for Mali Chat
class GroqService {
  
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
      
      print('Sending request to Groq with model: ${ApiConfig.defaultModel}');
      print('Request payload: ${jsonEncode({
        'model': ApiConfig.defaultModel,
        'messages': messages,
      })}');
      
      // Make API request with timeout
      final response = await http.post(
        Uri.parse('${ApiConfig.groqBaseUrl}/chat/completions'),
        headers: ApiConfig.groqHeaders,
        body: jsonEncode({
          'model': ApiConfig.defaultModel,
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
          'stream': false,
        }),
      ).timeout(const Duration(seconds: 30));
      
      print('Groq response status: ${response.statusCode}');
      print('Groq response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final aiResponse = data['choices'][0]['message']['content'] as String;
          print('AI Response: $aiResponse');
          return aiResponse;
        } else {
          throw Exception('No choices in API response: ${response.body}');
        }
      } else {
        throw Exception('Groq API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Groq API error: $e');
      throw Exception('Failed to get AI response from Groq: $e');
    }
  }
  
  /// Get Mali's financial coaching response using Groq
  static Future<String> getMaliCoachingResponse({
    required String userMessage,
    required Map<String, dynamic> financialContext,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final systemPrompt = '''
You are Mali, a sassy and supportive financial big sister. You help young women make smart money decisions with practical financial knowledge and a friendly, empowering tone.

Your personality traits:
- Supportive and encouraging, but also direct when needed
- Financially savvy with practical, actionable advice
- Empathetic but won't let users make excuses
- Celebrates wins and provides tough love when necessary
- Always maintain context from previous conversation
- Ask follow-up questions to better understand user needs

User's current financial context:
- Total Expenses: KES ${financialContext['totalExpenses']?.toStringAsFixed(0) ?? '0'}
- Total Income: KES ${financialContext['totalIncome']?.toStringAsFixed(0) ?? '0'}
- Active Goals: ${financialContext['activeGoals'] ?? 0}
- Budget Status: ${financialContext['budgetStatus'] ?? 'Unknown'}

Guidelines:
- Keep responses conversational, practical, and under 200 words
- Use emojis sparingly but effectively (2-3 max per response)
- Reference the user's financial data when relevant
- Provide actionable next steps
- If user is overspending, be supportive but firm
- If user is doing well, celebrate their progress
- Always maintain the conversation flow and context
- Speak only in English
- Be specific about amounts and percentages when relevant

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
      print('Groq API key not configured');
      return false;
    }
    
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.groqBaseUrl}/chat/completions'),
        headers: ApiConfig.groqHeaders,
        body: jsonEncode({
          'model': ApiConfig.defaultModel,
          'messages': [
            {'role': 'user', 'content': 'Hello, this is a test message.'}
          ],
          'max_tokens': 10,
        }),
      ).timeout(const Duration(seconds: 10));
      
      print('Groq test response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Groq connection test failed: $e');
      return false;
    }
  }
  
  /// Get available models from Groq
  static Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.groqBaseUrl}/models'),
        headers: ApiConfig.groqHeaders,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = (data['data'] as List)
            .map((model) => model['id'] as String)
            .where((id) => id.contains('llama') || id.contains('mixtral'))
            .toList();
        return models;
      }
    } catch (e) {
      print('Failed to get Groq models: $e');
    }
    
    return [ApiConfig.defaultModel, ApiConfig.alternativeModel];
  }
}
