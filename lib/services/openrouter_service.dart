import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service to interact with OpenRouter API for AI chat functionality
class OpenRouterService {
  /// Send a chat message and get AI response
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
      
      print('Sending request to OpenRouter with model: ${ApiConfig.defaultModel}');
      print('Request payload: ${jsonEncode({
        'model': ApiConfig.defaultModel,
        'messages': messages,
      })}');
      
      // Make API request
      final response = await http.post(
        Uri.parse('${ApiConfig.openRouterBaseUrl}/chat/completions'),
        headers: ApiConfig.openRouterHeaders,
        body: jsonEncode({
          'model': ApiConfig.defaultModel,
          'messages': messages,
        }),
      );
      
      print('OpenRouter response status: ${response.statusCode}');
      print('OpenRouter response body: ${response.body}');
      
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
        throw Exception('OpenRouter API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('OpenRouter API error: $e');
      throw Exception('Failed to get AI response: $e');
    }
  }
  
  /// Get Mali's financial coaching response
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

Remember: You're having a real conversation, not just answering individual questions. Build on previous messages and maintain continuity.
''';
    
    return await sendChatMessage(
      userMessage: userMessage,
      systemPrompt: systemPrompt,
      conversationHistory: conversationHistory,
    );
  }
  
  /// Get financial insights based on spending patterns
  static Future<String> getFinancialInsights({
    required List<Map<String, dynamic>> recentExpenses,
    required double monthlyIncome,
  }) async {
    final expensesSummary = recentExpenses.take(10).map((e) {
      return '${e['category']}: KES ${e['amount']}';
    }).join(', ');
    
    final systemPrompt = '''
You are Mali, a financial coach analyzing spending patterns. Provide brief, actionable insights.
''';
    
    final userMessage = '''
Analyze my recent spending:
$expensesSummary

Monthly income: KES $monthlyIncome

Give me 3 key insights and 1 actionable tip.
''';
    
    return await sendChatMessage(
      userMessage: userMessage,
      systemPrompt: systemPrompt,
    );
  }
}



