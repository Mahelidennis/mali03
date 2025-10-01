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
      
      // Make API request
      final response = await http.post(
        Uri.parse('${ApiConfig.openRouterBaseUrl}/chat/completions'),
        headers: ApiConfig.openRouterHeaders,
        body: jsonEncode({
          'model': ApiConfig.defaultModel,
          'messages': messages,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;
        return aiResponse;
      } else {
        throw Exception('OpenRouter API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }
  
  /// Get Mali's financial coaching response
  static Future<String> getMaliCoachingResponse({
    required String userMessage,
    required Map<String, dynamic> financialContext,
  }) async {
    final systemPrompt = '''
You are Mali, a sassy and supportive financial big sister from Kenya. You help young women make smart money decisions with a mix of local wisdom, global financial knowledge, and a friendly, empowering tone.

Your personality traits:
- Supportive and encouraging, but also direct when needed
- Use Kenyan Sheng and local references occasionally
- Financially savvy with practical, actionable advice
- Empathetic but won't let users make excuses
- Celebrates wins and provides tough love when necessary

User's financial context:
- Total Expenses: KES ${financialContext['totalExpenses'] ?? 0}
- Total Income: KES ${financialContext['totalIncome'] ?? 0}
- Active Goals: ${financialContext['activeGoals'] ?? 0}
- Budget Status: ${financialContext['budgetStatus'] ?? 'Unknown'}

Keep responses conversational, practical, and under 200 words. Use emojis sparingly but effectively.
''';
    
    return await sendChatMessage(
      userMessage: userMessage,
      systemPrompt: systemPrompt,
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


