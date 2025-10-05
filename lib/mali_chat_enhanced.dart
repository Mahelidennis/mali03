import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final String? messageType; // 'advice', 'insight', 'motivation', 'question'
  final Map<String, dynamic>? data; // Additional data for rich messages

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.messageType,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isFromUser': isFromUser,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType,
      'data': data,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isFromUser: json['isFromUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      messageType: json['messageType'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class MaliChatEnhanced extends StatefulWidget {
  const MaliChatEnhanced({super.key});

  @override
  State<MaliChatEnhanced> createState() => _MaliChatEnhancedState();
}

class _MaliChatEnhancedState extends State<MaliChatEnhanced> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Map<String, dynamic> _financialData = {};
  String _selectedVibe = 'Sassy & Bold';

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
    _loadUserVibe();
    _addWelcomeMessage();
  }

  Future<void> _loadFinancialData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load financial data
    final incomesString = prefs.getStringList('user_incomes') ?? [];
    final expensesString = prefs.getStringList('user_expenses') ?? [];
    final budgetsString = prefs.getStringList('user_budgets') ?? [];
    final goalsString = prefs.getStringList('user_goals') ?? [];
    
    // Process data
    List<Map<String, dynamic>> incomes = [];
    List<Map<String, dynamic>> expenses = [];
    List<Map<String, dynamic>> budgets = [];
    List<Map<String, dynamic>> goals = [];
    
    for (final incomeString in incomesString) {
      incomes.add(jsonDecode(incomeString));
    }
    for (final expenseString in expensesString) {
      expenses.add(jsonDecode(expenseString));
    }
    for (final budgetString in budgetsString) {
      budgets.add(jsonDecode(budgetString));
    }
    for (final goalString in goalsString) {
      goals.add(jsonDecode(goalString));
    }
    
    setState(() {
      _financialData = {
        'incomes': incomes,
        'expenses': expenses,
        'budgets': budgets,
        'goals': goals,
      };
    });
  }

  Future<void> _loadUserVibe() async {
    final prefs = await SharedPreferences.getInstance();
    final vibe = prefs.getString('selected_vibe') ?? 'Sassy & Bold';
    setState(() {
      _selectedVibe = vibe;
    });
  }

  void _addWelcomeMessage() {
    final welcomeMessages = {
      'Sassy & Bold': [
        "Hey there, future boss babe! 💅 Ready to slay your financial goals? I'm here to help you become the money queen you were meant to be!",
        "What's up, financial warrior? 💪 Let's make your money work harder than you do!",
        "Hey gorgeous! 💖 Ready to turn your financial dreams into reality? I've got your back!",
      ],
      'Encouraging & Gentle': [
        "Hello! 🌸 I'm here to gently guide you on your financial journey. Let's take this step by step together.",
        "Hi there! 💙 I'm Mali, your supportive financial companion. How can I help you today?",
        "Welcome! 🌺 I'm here to encourage and support you in achieving your financial goals.",
      ],
      'No-Nonsense & Direct': [
        "Hello. I'm Mali. Let's get straight to your financial situation and make it better.",
        "Hi. I'm here to help you manage your money effectively. What do you need?",
        "Welcome. I'll give you direct, actionable financial advice. What's your situation?",
      ],
    };

    final messages = welcomeMessages[_selectedVibe] ?? welcomeMessages['Sassy & Bold']!;
    final randomMessage = messages[Random().nextInt(messages.length)];
    
    _messages.add(ChatMessage(
      text: randomMessage,
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'welcome',
    ));
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isFromUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI processing time
    await Future.delayed(const Duration(milliseconds: 1500));

    final response = await _generateResponse(text);
    
    setState(() {
      _messages.add(response);
      _isLoading = false;
    });

    _scrollToBottom();
  }

  Future<ChatMessage> _generateResponse(String userMessage) async {
    final message = userMessage.toLowerCase();
    
    // Financial insights and advice
    if (message.contains('spending') || message.contains('expense') || message.contains('money')) {
      return _generateSpendingInsight();
    }
    
    if (message.contains('budget') || message.contains('limit')) {
      return _generateBudgetAdvice();
    }
    
    if (message.contains('goal') || message.contains('save') || message.contains('target')) {
      return _generateGoalAdvice();
    }
    
    if (message.contains('income') || message.contains('earn') || message.contains('salary')) {
      return _generateIncomeAdvice();
    }
    
    if (message.contains('debt') || message.contains('loan') || message.contains('credit')) {
      return _generateDebtAdvice();
    }
    
    if (message.contains('investment') || message.contains('invest') || message.contains('stock')) {
      return _generateInvestmentAdvice();
    }
    
    if (message.contains('emergency') || message.contains('fund') || message.contains('safety')) {
      return _generateEmergencyFundAdvice();
    }
    
    if (message.contains('help') || message.contains('advice') || message.contains('tips')) {
      return _generateGeneralAdvice();
    }
    
    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return _generateGreeting();
    }
    
    if (message.contains('thank') || message.contains('thanks')) {
      return _generateThanksResponse();
    }
    
    // Default response
    return _generateDefaultResponse();
  }

  ChatMessage _generateSpendingInsight() {
    final expenses = _financialData['expenses'] as List<Map<String, dynamic>>;
    if (expenses.isEmpty) {
      return ChatMessage(
        text: _getVibeResponse('spending', "I don't see any spending data yet. Start tracking your expenses so I can give you personalized insights! 💡"),
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: 'insight',
      );
    }

    // Calculate spending insights
    final currentMonth = DateTime.now();
    final monthlyExpenses = expenses.where((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      return expenseDate.year == currentMonth.year && expenseDate.month == currentMonth.month;
    }).toList();

    if (monthlyExpenses.isEmpty) {
      return ChatMessage(
        text: _getVibeResponse('spending', "No expenses this month yet! That's great - you're starting fresh! 🎉"),
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: 'insight',
      );
    }

    final totalSpending = monthlyExpenses.fold(0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
    final categoryBreakdown = <String, double>{};
    
    for (final expense in monthlyExpenses) {
      final category = expense['category'] ?? 'Other';
      categoryBreakdown[category] = (categoryBreakdown[category] ?? 0.0) + (expense['amount'] ?? 0.0);
    }

    final topCategory = categoryBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b);
    final topCategoryPercentage = (topCategory.value / totalSpending) * 100;

    String response;
    if (topCategoryPercentage > 40) {
      response = "You're spending ${topCategoryPercentage.toStringAsFixed(0)}% of your money on ${topCategory.key}! That's quite a lot. Maybe we should look at ways to reduce this? 💰";
    } else if (topCategoryPercentage > 25) {
      response = "Your biggest expense category is ${topCategory.key} at ${topCategoryPercentage.toStringAsFixed(0)}%. That's reasonable, but let's see if we can optimize! 📊";
    } else {
      response = "Great spending distribution! Your top category (${topCategory.key}) is only ${topCategoryPercentage.toStringAsFixed(0)}% of your total spending. You're doing well! 👏";
    }

    return ChatMessage(
      text: _getVibeResponse('spending', response),
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'insight',
      data: {
        'totalSpending': totalSpending,
        'topCategory': topCategory.key,
        'topCategoryAmount': topCategory.value,
        'topCategoryPercentage': topCategoryPercentage,
      },
    );
  }

  ChatMessage _generateBudgetAdvice() {
    final budgets = _financialData['budgets'] as List<Map<String, dynamic>>;
    final expenses = _financialData['expenses'] as List<Map<String, dynamic>>;
    
    if (budgets.isEmpty) {
      return ChatMessage(
        text: _getVibeResponse('budget', "You don't have any budgets set up yet! Setting budgets is crucial for financial success. Would you like me to help you create some? 📋"),
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: 'advice',
      );
    }

    // Check budget performance
    final currentMonth = DateTime.now();
    final monthlyExpenses = expenses.where((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      return expenseDate.year == currentMonth.year && expenseDate.month == currentMonth.month;
    }).toList();

    int overBudgetCount = 0;
    int underBudgetCount = 0;
    String overBudgetCategory = '';

    for (final budget in budgets) {
      if (budget['period'] == 'Monthly') {
        final category = budget['category'];
        final budgetAmount = budget['amount'];
        final spentAmount = monthlyExpenses
            .where((expense) => expense['category'] == category)
            .fold(0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
        
        if (spentAmount > budgetAmount) {
          overBudgetCount++;
          if (overBudgetCategory.isEmpty) overBudgetCategory = category;
        } else {
          underBudgetCount++;
        }
      }
    }

    String response;
    if (overBudgetCount > 0) {
      response = "You're over budget in $overBudgetCount category${overBudgetCount > 1 ? 's' : ''}! ${overBudgetCategory.isNotEmpty ? 'Especially in $overBudgetCategory.' : ''} Let's work on reducing these expenses! 🚨";
    } else if (underBudgetCount > 0) {
      response = "Excellent! You're staying within budget in all categories! Keep up the great work! 🎉";
    } else {
      response = "Your budget performance looks good! You're managing your spending well! 💪";
    }

    return ChatMessage(
      text: _getVibeResponse('budget', response),
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'advice',
      data: {
        'overBudgetCount': overBudgetCount,
        'underBudgetCount': underBudgetCount,
        'overBudgetCategory': overBudgetCategory,
      },
    );
  }

  ChatMessage _generateGoalAdvice() {
    final goals = _financialData['goals'] as List<Map<String, dynamic>>;
    
    if (goals.isEmpty) {
      return ChatMessage(
        text: _getVibeResponse('goal', "You don't have any financial goals set yet! Setting clear goals is the first step to financial success. What would you like to achieve? 🎯"),
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: 'advice',
      );
    }

    final activeGoals = goals.where((goal) => !goal['isCompleted']).toList();
    final completedGoals = goals.where((goal) => goal['isCompleted']).toList();
    
    if (activeGoals.isEmpty && completedGoals.isNotEmpty) {
      return ChatMessage(
        text: _getVibeResponse('goal', "Amazing! You've completed all your goals! 🎉 Time to set some new ones and keep the momentum going!"),
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: 'motivation',
      );
    }

    // Find goals that need attention
    final now = DateTime.now();
    final overdueGoals = activeGoals.where((goal) {
      final targetDate = DateTime.parse(goal['targetDate']);
      return targetDate.isBefore(now);
    }).toList();

    final nearDeadlineGoals = activeGoals.where((goal) {
      final targetDate = DateTime.parse(goal['targetDate']);
      final daysRemaining = targetDate.difference(now).inDays;
      return daysRemaining <= 7 && daysRemaining > 0;
    }).toList();

    String response;
    if (overdueGoals.isNotEmpty) {
      response = "You have ${overdueGoals.length} overdue goal${overdueGoals.length > 1 ? 's' : ''}! Let's reassess these and get back on track! ⏰";
    } else if (nearDeadlineGoals.isNotEmpty) {
      response = "You have ${nearDeadlineGoals.length} goal${nearDeadlineGoals.length > 1 ? 's' : ''} due within a week! Time to push hard! 💪";
    } else {
      response = "You're doing great with your goals! Keep up the momentum and stay focused! 🚀";
    }

    return ChatMessage(
      text: _getVibeResponse('goal', response),
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'advice',
      data: {
        'activeGoals': activeGoals.length,
        'completedGoals': completedGoals.length,
        'overdueGoals': overdueGoals.length,
        'nearDeadlineGoals': nearDeadlineGoals.length,
      },
    );
  }

  ChatMessage _generateIncomeAdvice() {
    final incomes = _financialData['incomes'] as List<Map<String, dynamic>>;
    
    if (incomes.isEmpty) {
      return ChatMessage(
        text: _getVibeResponse('income', "I don't see any income data yet! Start tracking your income sources so I can help you optimize your earnings! 💰"),
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: 'advice',
      );
    }

    final currentMonth = DateTime.now();
    final monthlyIncomes = incomes.where((income) {
      final incomeDate = DateTime.parse(income['date']);
      return incomeDate.year == currentMonth.year && incomeDate.month == currentMonth.month;
    }).toList();

    if (monthlyIncomes.isEmpty) {
      return ChatMessage(
        text: _getVibeResponse('income', "No income recorded this month yet! Make sure to track all your income sources! 📈"),
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: 'advice',
      );
    }

    final totalIncome = monthlyIncomes.fold(0.0, (sum, income) => sum + (income['amount'] ?? 0.0));
    final sourceBreakdown = <String, double>{};
    
    for (final income in monthlyIncomes) {
      final source = income['source'] ?? 'Other';
      sourceBreakdown[source] = (sourceBreakdown[source] ?? 0.0) + (income['amount'] ?? 0.0);
    }

    final topSource = sourceBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b);
    final topSourcePercentage = (topSource.value / totalIncome) * 100;

    String response;
    if (topSourcePercentage > 80) {
      response = "You're heavily dependent on ${topSource.key} for ${topSourcePercentage.toStringAsFixed(0)}% of your income! Consider diversifying your income sources for better financial security! 🎯";
    } else if (topSourcePercentage > 50) {
      response = "Your main income source is ${topSource.key} at ${topSourcePercentage.toStringAsFixed(0)}%. That's good, but diversifying could make you more resilient! 💪";
    } else {
      response = "Great income diversification! You're not too dependent on any single source. That's smart financial planning! 🌟";
    }

    return ChatMessage(
      text: _getVibeResponse('income', response),
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'advice',
      data: {
        'totalIncome': totalIncome,
        'topSource': topSource.key,
        'topSourceAmount': topSource.value,
        'topSourcePercentage': topSourcePercentage,
      },
    );
  }

  ChatMessage _generateDebtAdvice() {
    return ChatMessage(
      text: _getVibeResponse('debt', "Debt management is crucial! Here are some key strategies: 1) Pay high-interest debt first, 2) Consider debt consolidation, 3) Build an emergency fund to avoid new debt, 4) Create a debt payoff plan! 💳"),
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'advice',
    );
  }

  ChatMessage _generateInvestmentAdvice() {
    return ChatMessage(
      text: _getVibeResponse('investment', "Smart investing starts with: 1) Understanding your risk tolerance, 2) Diversifying your portfolio, 3) Starting early with compound interest, 4) Regular contributions, 5) Long-term thinking! 📈"),
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'advice',
    );
  }

  ChatMessage _generateEmergencyFundAdvice() {
    return ChatMessage(
      text: _getVibeResponse('emergency', "Emergency funds are your financial safety net! Aim for 3-6 months of expenses. Start small - even Ksh 1,000/month adds up! This fund prevents you from going into debt during emergencies! 🛡️"),
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'advice',
    );
  }

  ChatMessage _generateGeneralAdvice() {
    final adviceMessages = {
      'Sassy & Bold': [
        "Here's the tea, sis! 💅 Track every shilling, set clear goals, and don't let anyone tell you you can't be financially fabulous!",
        "Listen up, queen! 👑 Budget like your future depends on it (because it does!), save consistently, and invest in yourself!",
        "Real talk, babe! 💪 Know where your money goes, pay yourself first, and remember - you're worth every financial goal you set!",
      ],
      'Encouraging & Gentle': [
        "Here are some gentle tips: 🌸 Start small with your financial goals, be patient with yourself, and celebrate every small win!",
        "Remember, dear: 💙 Financial success is a journey, not a race. Take it one step at a time and be kind to yourself!",
        "You've got this! 🌺 Start by tracking your expenses, set realistic goals, and remember that every small step counts!",
      ],
      'No-Nonsense & Direct': [
        "Here's what you need to do: Track expenses, create a budget, set financial goals, build an emergency fund, and invest consistently.",
        "Financial success requires: Discipline, planning, consistency, and patience. Start with the basics and stick to them.",
        "Key principles: Spend less than you earn, save regularly, invest wisely, and avoid unnecessary debt. That's it.",
      ],
    };

    final messages = adviceMessages[_selectedVibe] ?? adviceMessages['Sassy & Bold']!;
    final randomMessage = messages[Random().nextInt(messages.length)];

    return ChatMessage(
      text: randomMessage,
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'advice',
    );
  }

  ChatMessage _generateGreeting() {
    final greetingMessages = {
      'Sassy & Bold': [
        "Hey gorgeous! 💅 Ready to slay those financial goals?",
        "What's up, future millionaire? 💰",
        "Hello there, boss babe! 👑",
      ],
      'Encouraging & Gentle': [
        "Hello! 🌸 How can I help you today?",
        "Hi there! 💙 I'm here to support you!",
        "Welcome! 🌺 Let's work together!",
      ],
      'No-Nonsense & Direct': [
        "Hello. What do you need help with?",
        "Hi. How can I assist you?",
        "Hello. What's your financial question?",
      ],
    };

    final messages = greetingMessages[_selectedVibe] ?? greetingMessages['Sassy & Bold']!;
    final randomMessage = messages[Random().nextInt(messages.length)];

    return ChatMessage(
      text: randomMessage,
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'greeting',
    );
  }

  ChatMessage _generateThanksResponse() {
    final thanksMessages = {
      'Sassy & Bold': [
        "You're welcome, queen! 💅 Keep slaying those financial goals!",
        "Anytime, boss babe! 👑 You've got this!",
        "No problem, gorgeous! 💖 I'm always here for you!",
      ],
      'Encouraging & Gentle': [
        "You're very welcome! 🌸 I'm happy to help!",
        "Of course! 💙 That's what I'm here for!",
        "My pleasure! 🌺 Keep up the great work!",
      ],
      'No-Nonsense & Direct': [
        "You're welcome. Keep working on your financial goals.",
        "No problem. Stay focused on your objectives.",
        "Welcome. Continue making progress.",
      ],
    };

    final messages = thanksMessages[_selectedVibe] ?? thanksMessages['Sassy & Bold']!;
    final randomMessage = messages[Random().nextInt(messages.length)];

    return ChatMessage(
      text: randomMessage,
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'thanks',
    );
  }

  ChatMessage _generateDefaultResponse() {
    final defaultMessages = {
      'Sassy & Bold': [
        "Hmm, I'm not sure about that one, babe! 💅 Try asking me about your spending, budgets, goals, or income!",
        "That's not quite my area, sis! 👑 I'm your financial advisor - ask me about money matters!",
        "I'm not following, gorgeous! 💖 Ask me about your finances and I'll help you out!",
      ],
      'Encouraging & Gentle': [
        "I'm not sure I understand that, dear. 🌸 Try asking me about your financial situation!",
        "That's outside my expertise, but I'm here to help with money matters! 💙",
        "I'm not sure about that one. 🌺 Ask me about your spending, savings, or financial goals!",
      ],
      'No-Nonsense & Direct': [
        "I don't understand that. Ask me about your financial situation, spending, or goals.",
        "That's not something I can help with. Focus on financial questions.",
        "I'm not sure what you mean. Ask me about money management.",
      ],
    };

    final messages = defaultMessages[_selectedVibe] ?? defaultMessages['Sassy & Bold']!;
    final randomMessage = messages[Random().nextInt(messages.length)];

    return ChatMessage(
      text: randomMessage,
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'default',
    );
  }

  String _getVibeResponse(String context, String baseResponse) {
    // Add vibe-specific enhancements to responses
    switch (_selectedVibe) {
      case 'Sassy & Bold':
        return baseResponse;
      case 'Encouraging & Gentle':
        return baseResponse.replaceAll('!', '.').replaceAll('💅', '🌸').replaceAll('👑', '💙');
      case 'No-Nonsense & Direct':
        return baseResponse.replaceAll(RegExp(r'[💅👑💖💰💪🎉🚨📊🎯🛡️💳📈🌸💙🌺]'), '');
      default:
        return baseResponse;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEE2B8D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Mali',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEE2B8D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _selectedVibe.split(' ').first,
                style: const TextStyle(
                  color: Color(0xFFEE2B8D),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingMessage();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEE2B8D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isFromUser 
                    ? const Color(0xFFEE2B8D)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isFromUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  if (message.data != null) ...[
                    const SizedBox(height: 8),
                    _buildMessageData(message.data!),
                  ],
                ],
              ),
            ),
          ),
          if (message.isFromUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageData(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.containsKey('totalSpending'))
            _buildDataRow('Total Spending', 'Ksh ${data['totalSpending'].toStringAsFixed(0)}'),
          if (data.containsKey('topCategory'))
            _buildDataRow('Top Category', '${data['topCategory']} (${data['topCategoryPercentage'].toStringAsFixed(0)}%)'),
          if (data.containsKey('totalIncome'))
            _buildDataRow('Total Income', 'Ksh ${data['totalIncome'].toStringAsFixed(0)}'),
          if (data.containsKey('topSource'))
            _buildDataRow('Top Source', '${data['topSource']} (${data['topSourcePercentage'].toStringAsFixed(0)}%)'),
          if (data.containsKey('activeGoals'))
            _buildDataRow('Active Goals', '${data['activeGoals']}'),
          if (data.containsKey('completedGoals'))
            _buildDataRow('Completed Goals', '${data['completedGoals']}'),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEE2B8D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE2B8D)),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Mali is thinking...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F0F2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask Mali about your finances...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEE2B8D),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
