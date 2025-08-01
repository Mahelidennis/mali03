import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_profile.dart';

class MaliAIService {
  // In production, this should be stored securely on a backend server
  static const String _apiKey = 'your-openai-api-key';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static String getMaliResponse({
    required String userMessage,
    required UserProfile? userProfile,
  }) {
    // For now, use local responses for speed
    return _getFallbackResponse(userMessage, userProfile);
  }

  static Future<String> _callOpenAI(String userMessage, UserProfile? userProfile) async {
    final prompt = _buildPrompt(userMessage, userProfile);

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': _getSystemPrompt(),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'max_tokens': 300,
        'temperature': 0.8,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('API call failed');
    }
  }

  static String _getSystemPrompt() {
    return '''
You are Mali, a Kenyan financial assistant with a big sister personality. You provide financial advice with:

1. **Kenyan Context**: Use KSh currency, mention M-Pesa, local banks, Kenyan lifestyle
2. **Personality**: Be sassy, supportive, and use local Kenyan slang/humor
3. **Gender Awareness**: Address users as "Girl" (female) or "Bro" (male)
4. **Financial Education**: Provide practical, actionable advice
5. **Cultural Relevance**: Reference Kenyan spending habits, local brands

Key guidelines:
- Use emojis and be conversational
- Reference local financial products (M-Akiba, SACCOs)
- Be encouraging but honest about financial habits
- Use Kenyan examples and scenarios
- Keep responses under 150 words
- Be supportive but can gently roast overspending
- Use "Girl" or "Bro" in responses
- Be friendly and supportive like a big sister
''';
  }

  static String _buildPrompt(String userMessage, UserProfile? userProfile) {
    final gender = userProfile?.genderGreeting ?? 'Girl';
    final pronoun = userProfile?.genderPronoun ?? 'sister';
    final income = userProfile?.monthlyIncome ?? 0.0;
    final goal = userProfile?.primaryGoal ?? 'Save Money';

    return '''
User Message: "$userMessage"

User Profile:
- Gender: ${userProfile?.gender.name ?? 'unknown'}
- Monthly Income: KSh ${income.toStringAsFixed(0)}
- Primary Goal: $goal
- Language: ${userProfile?.preferredLanguage ?? 'en'}

Respond as Mali with Kenyan context and personality. Address user as "$gender" and use "$pronoun" in your response.
''';
  }

  static String _getFallbackResponse(String userMessage, UserProfile? userProfile) {
    final greeting = userProfile?.genderGreeting ?? 'Girl';
    final pronoun = userProfile?.genderPronoun ?? 'sister';
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('spend') || lowerMessage.contains('money') || lowerMessage.contains('buy')) {
      return "$greeting, you spending money like it's going out of style! 😂 What did you buy this time? Let me help you track that spending! 💰";
    } else if (lowerMessage.contains('save') || lowerMessage.contains('saving')) {
      return "$greeting, that's what I like to hear! 💪 Saving money is the key to financial freedom! Let's set some goals together! 🎯";
    } else if (lowerMessage.contains('budget') || lowerMessage.contains('budgeting')) {
      return "$greeting, budgeting is your best friend! 💡 Start by tracking your expenses, then create a realistic budget. I'm here to help! 📊";
    } else if (lowerMessage.contains('goal') || lowerMessage.contains('target')) {
      return "$greeting, goals are everything! 🎯 What do you want to achieve? A new phone? Vacation? Emergency fund? Tell me and I'll help you get there! ✨";
    } else if (lowerMessage.contains('income') || lowerMessage.contains('salary')) {
      return "$greeting, money coming in! 💰 That's what I like to hear! How are you planning to use it? Let's make sure you're not just spending it all! 💅";
    } else if (lowerMessage.contains('debt') || lowerMessage.contains('loan')) {
      return "$greeting, debt is like a heavy backpack! 💼 Let's work on paying it off together. Start with the highest interest rate first! 💪";
    } else if (lowerMessage.contains('invest') || lowerMessage.contains('investment')) {
      return "$greeting, investing is smart! 📈 Start small with M-Akiba or SACCOs. Every shilling counts! Let's grow your money together! 🚀";
    } else {
      return "$greeting, I'm here to help you with all things money! 💰 Whether it's spending, saving, budgeting, or investing - just ask! 💪";
    }
  }

  // Custom command responses
  static String getSpendingSummary(UserProfile? userProfile) {
    final greeting = userProfile?.genderGreeting ?? 'Girl';
    return "$greeting, here's your spending summary for this month! 💰\n\n📊 **This Month's Spending:**\n• Coffee & Food: KSh 8,500 ☕\n• Transport: KSh 5,200 🚗\n• Shopping: KSh 12,000 🛍️\n• Bills: KSh 15,000 📱\n\n💰 **Total: KSh 40,700**\n\nGirl, you're spending KSh 8,500 on coffee alone! That's like buying a new phone every 4 months! 😂 Maybe try making coffee at home? 💡";
  }

  static String getGoalProgress(UserProfile? userProfile) {
    final greeting = userProfile?.genderGreeting ?? 'Girl';
    final pronoun = userProfile?.genderPronoun ?? 'sister';
    return "$greeting, let's check your goals! 🎯\n\n📈 **Goal Progress:**\n• Emergency Fund: 75% complete 💪\n• Vacation Fund: 40% complete ✈️\n• New Phone: 60% complete 📱\n\nYou're doing amazing, $pronoun! Keep pushing! 🔥\n\nWant to set a new goal? Just tell me!";
  }

  static String getBudgetTips(UserProfile? userProfile) {
    final greeting = userProfile?.genderGreeting ?? 'Girl';
    return "$greeting, here are your personalized budget tips! 💡\n\n💡 **Mali's Budget Tips:**\n• Track your coffee spending - it adds up! ☕\n• Use the 50/30/20 rule: 50% needs, 30% wants, 20% savings\n• Set up automatic transfers to savings\n• Cook at home 3x more this month\n• Use public transport for short distances\n\nRemember, every shilling counts! 💪";
  }

  static String getHelpMessage() {
    return "Here are the commands I understand, girl! 💅\n\n📋 **Available Commands:**\n• `/spending-summary` - Get your spending breakdown\n• `/goal-progress` - Check your financial goals\n• `/budget-tips` - Get personalized budget advice\n• `/help` - Show this help message\n\n💬 **Or just chat with me normally!**\n\nTry asking me anything about your money! 💰";
  }
} 