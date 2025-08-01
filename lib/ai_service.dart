import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_profile.dart';
import 'expense_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  // In production, this would be stored securely
  static const String _apiKey = 'your-openai-api-key';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String> getPersonalizedAdvice({
    required String userMessage,
    required UserProfile? userProfile,
    required Map<String, dynamic> financialData,
  }) async {
    try {
      final prompt = await _buildPrompt(userMessage, userProfile, financialData);
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini', // Using GPT-4o-mini for better responses
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
          'max_tokens': 400,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        // Fallback to local responses if API fails
        return _getFallbackResponse(userMessage, userProfile, financialData);
      }
    } catch (e) {
      // Fallback to local responses
      return _getFallbackResponse(userMessage, userProfile, financialData);
    }
  }

  static String _getSystemPrompt() {
    return '''
You are Mali, a Kenyan financial assistant with a big sister/brother personality. You provide financial advice with:

1. **Kenyan Context**: Use KSh currency, mention M-Pesa, SACCOs, chamas, local banks, Kenyan lifestyle
2. **Personality**: Be sassy, supportive, and use local Kenyan slang/humor
3. **Gender Awareness**: Address users as "Girl" (female) or "Bro" (male)
4. **Financial Education**: Provide practical, actionable advice
5. **Cultural Relevance**: Reference Kenyan lifestyle, spending habits, local brands

Key guidelines:
- Use emojis and be conversational
- Reference local financial products (M-Akiba, SACCOs, mobile banking)
- Be encouraging but honest about financial habits
- Use Kenyan examples and scenarios
- Keep responses under 200 words
- Be supportive but can gently roast overspending
- Use "Girl" or "Bro" in responses
- Be friendly and supportive like a big sister/brother
- Provide specific, actionable advice
- Reference the user's financial data when available
''';
  }

  static Future<String> _buildPrompt(String userMessage, UserProfile? userProfile, Map<String, dynamic> financialData) async {
    final gender = userProfile?.genderGreeting ?? 'Hey';
    final pronoun = userProfile?.genderPronoun ?? 'sister';
    final income = userProfile?.monthlyIncome ?? 0.0;
    final interests = userProfile?.interests.join(', ') ?? '';

    // Get real financial data
    final currentMonth = DateTime.now();
    final expenses = await ExpenseTracker.getExpensesByMonth(currentMonth);
    final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
    
    // Get income data
    final prefs = await SharedPreferences.getInstance();
    final incomesString = prefs.getStringList('user_incomes') ?? [];
    double totalIncome = 0;
    for (final incomeString in incomesString) {
      final incomeData = jsonDecode(incomeString);
      final incomeDate = DateTime.parse(incomeData['date']);
      if (incomeDate.year == currentMonth.year && incomeDate.month == currentMonth.month) {
        totalIncome += incomeData['amount'];
      }
    }

    return '''
User Message: "$userMessage"

User Profile:
- Gender: ${userProfile?.gender.name ?? 'unknown'}
- Monthly Income: KSh ${income.toStringAsFixed(0)}
- Interests: $interests
- Language: ${userProfile?.preferredLanguage ?? 'en'}

Real Financial Data:
- Total Income This Month: KSh ${totalIncome.toStringAsFixed(0)}
- Total Spending This Month: KSh ${spendingInsights['total_spending'].toStringAsFixed(0)}
- Top Spending Category: ${spendingInsights['top_category']}
- Top Spending Amount: KSh ${spendingInsights['top_amount'].toStringAsFixed(0)}
- Average Daily Spending: KSh ${spendingInsights['average_daily'].toStringAsFixed(0)}
- Number of Expenses: ${spendingInsights['expense_count']}
- Category Breakdown: ${spendingInsights['category_breakdown']}

Respond as Mali with Kenyan context and personality. Address user as "$gender" and use "$pronoun" in your response. Use the real financial data to give personalized advice.
''';
  }

  static String _getFallbackResponse(String userMessage, UserProfile? userProfile, Map<String, dynamic> financialData) {
    final lowerMessage = userMessage.toLowerCase();
    final greeting = userProfile?.genderGreeting ?? 'Hey';
    final pronoun = userProfile?.genderPronoun ?? 'sister';

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
} 