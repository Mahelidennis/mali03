import 'package:flutter/material.dart';
import 'user_profile.dart';
import 'ai_service.dart';
import 'financial_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_tracker.dart';
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  
  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _addWelcomeMessage();
    
    // If there's an initial message, add it and get Mali's response
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addUserMessage(widget.initialMessage!);
        _addMaliResponse(widget.initialMessage!);
      });
    }
  }

  Future<void> _loadUserProfile() async {
    final profile = await UserProfileManager.getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    final isCommand = message.startsWith('/');

    // Add user message
    _messages.add(ChatMessage(
      text: message,
      isFromUser: true,
      timestamp: DateTime.now(),
    ));

    setState(() {
      _messageController.clear();
    });

    // Handle command or get AI response
    if (isCommand) {
      _handleCommand(message);
    } else {
      // Check if message contains financial transaction
      final transaction = _extractTransaction(message);
      if (transaction != null) {
        _processTransaction(transaction, message);
      } else {
        _addMaliResponse(message);
      }
    }

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Extract financial transaction from message
  Map<String, dynamic>? _extractTransaction(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Income patterns
    final incomePatterns = [
      RegExp(r'i (?:have|got|received|earned) (?:an? )?income of (\d+(?:,\d+)*)'),
      RegExp(r'i (?:have|got|received|earned) (\d+(?:,\d+)*) (?:as|from) (?:income|salary|payment)'),
      RegExp(r'income: (\d+(?:,\d+)*)'),
      RegExp(r'salary: (\d+(?:,\d+)*)'),
    ];

    // Expense patterns
    final expensePatterns = [
      RegExp(r'i (?:spent|paid|bought|purchased) (\d+(?:,\d+)*) (?:on|for) (.+)'),
      RegExp(r'i (?:spent|paid|bought|purchased) (\d+(?:,\d+)*)'),
      RegExp(r'expense: (\d+(?:,\d+)*) (?:on|for) (.+)'),
      RegExp(r'(\d+(?:,\d+)*) (?:on|for) (.+)'),
    ];

    // Goal patterns
    final goalPatterns = [
      RegExp(r'i want to save (\d+(?:,\d+)*) (?:for|to) (.+)'),
      RegExp(r'goal: (\d+(?:,\d+)*) (?:for|to) (.+)'),
      RegExp(r'save (\d+(?:,\d+)*) (?:for|to) (.+)'),
    ];

    // Check for income
    for (final pattern in incomePatterns) {
      final match = pattern.firstMatch(lowerMessage);
      if (match != null) {
        final amount = _parseAmount(match.group(1)!);
        return {
          'type': 'income',
          'amount': amount,
          'title': 'Income from chat',
          'category': 'Other',
          'note': message,
        };
      }
    }

    // Check for expenses
    for (final pattern in expensePatterns) {
      final match = pattern.firstMatch(lowerMessage);
      if (match != null) {
        final amount = _parseAmount(match.group(1)!);
        final description = match.group(2) ?? 'General expense';
        final category = _categorizeExpense(description);
        return {
          'type': 'expense',
          'amount': amount,
          'title': description,
          'category': category,
          'note': message,
        };
      }
    }

    // Check for goals
    for (final pattern in goalPatterns) {
      final match = pattern.firstMatch(lowerMessage);
      if (match != null) {
        final amount = _parseAmount(match.group(1)!);
        final goal = match.group(2) ?? 'General goal';
        return {
          'type': 'goal',
          'amount': amount,
          'title': goal,
          'category': 'Savings',
          'note': message,
        };
      }
    }

    return null;
  }

  // Parse amount string to double
  double _parseAmount(String amountStr) {
    return double.parse(amountStr.replaceAll(',', ''));
  }

  // Categorize expense based on description
  String _categorizeExpense(String description) {
    final lowerDesc = description.toLowerCase();
    
    if (lowerDesc.contains('food') || lowerDesc.contains('lunch') || lowerDesc.contains('dinner') || lowerDesc.contains('breakfast')) {
      return 'Food';
    } else if (lowerDesc.contains('transport') || lowerDesc.contains('uber') || lowerDesc.contains('taxi') || lowerDesc.contains('bus')) {
      return 'Transport';
    } else if (lowerDesc.contains('hair') || lowerDesc.contains('beauty') || lowerDesc.contains('makeup') || lowerDesc.contains('salon')) {
      return 'Beauty';
    } else if (lowerDesc.contains('shopping') || lowerDesc.contains('clothes') || lowerDesc.contains('dress')) {
      return 'Shopping';
    } else if (lowerDesc.contains('coffee') || lowerDesc.contains('tea')) {
      return 'Coffee';
    } else if (lowerDesc.contains('grocery') || lowerDesc.contains('market')) {
      return 'Groceries';
    } else {
      return 'Other';
    }
  }

  // Process the extracted transaction
  Future<void> _processTransaction(Map<String, dynamic> transaction, String originalMessage) async {
    final type = transaction['type'];
    final amount = transaction['amount'];
    final title = transaction['title'];
    final category = transaction['category'];
    final note = transaction['note'];

    String response = '';

    if (type == 'income') {
      // Add to income tracker
      await _addIncome(amount, title, category, note);
      
      // Get financial insights for personalized response
      final currentMonth = DateTime.now();
      final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
      final totalSpending = spendingInsights['total_spending'] ?? 0.0;
      final savings = amount - totalSpending;
      
      if (savings > 0) {
        response = "Girl, that's amazing! 💰 I've added KSh ${amount.toStringAsFixed(0)} to your income. With your current spending of KSh ${totalSpending.toStringAsFixed(0)}, you could save KSh ${savings.toStringAsFixed(0)} this month! That's ${(savings/amount*100).toStringAsFixed(0)}% savings rate - you're killing it! 💅";
      } else {
        response = "Girl, that's amazing! 💰 I've added KSh ${amount.toStringAsFixed(0)} to your income. But girl, you're spending KSh ${totalSpending.toStringAsFixed(0)} this month - that's more than your income! Let's work on that budget together! 💪";
      }
    } else if (type == 'expense') {
      // Add to expense tracker
      await _addExpense(amount, title, category, note);
      
      // Get spending insights for personalized response
      final currentMonth = DateTime.now();
      final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
      final totalSpending = spendingInsights['total_spending'] ?? 0.0;
      final topCategory = spendingInsights['top_category'] ?? '';
      final topAmount = spendingInsights['top_amount'] ?? 0.0;
      
      if (category == topCategory && amount > topAmount * 0.5) {
        response = "Girl, I've recorded your KSh ${amount.toStringAsFixed(0)} spending on $title. 💸 This is your biggest $category expense this month! Maybe we should set a budget for $category? 💡";
      } else if (amount > 10000) {
        response = "Girl, I've recorded your KSh ${amount.toStringAsFixed(0)} spending on $title. 💸 That's a big purchase! Are you sure this fits your budget? Let me help you track this! 💪";
      } else {
        response = "Girl, I've recorded your KSh ${amount.toStringAsFixed(0)} spending on $title. 💸 Your total spending this month is KSh ${totalSpending.toStringAsFixed(0)}. Keep tracking, $category! 📊";
      }
    } else if (type == 'goal') {
      // Add to goals
      await _addGoal(amount, title, category, note);
      
      // Get current savings for goal advice
      final currentMonth = DateTime.now();
      final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
      final totalSpending = spendingInsights['total_spending'] ?? 0.0;
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
      final monthlySavings = totalIncome - totalSpending;
      final monthsToGoal = monthlySavings > 0 ? (amount / monthlySavings).ceil() : 999;
      
      if (monthsToGoal <= 6) {
        response = "Love the goal-setting energy! 🎯 I've added your KSh ${amount.toStringAsFixed(0)} goal for $title. With your current savings rate, you could reach this in $monthsToGoal months! Let's work together to reach it! 💪";
      } else if (monthsToGoal <= 12) {
        response = "Love the goal-setting energy! 🎯 I've added your KSh ${amount.toStringAsFixed(0)} goal for $title. This will take about $monthsToGoal months at your current rate. Want to increase your savings? 💡";
      } else {
        response = "Love the goal-setting energy! 🎯 I've added your KSh ${amount.toStringAsFixed(0)} goal for $title. This is a big goal! Let's work on increasing your savings rate to reach it faster! 💪";
      }
    }

    // Add Mali's response
    _addMaliResponse(response);
  }

  // Add income to tracker
  Future<void> _addIncome(double amount, String title, String category, String note) async {
    final prefs = await SharedPreferences.getInstance();
    final incomeData = {
      'amount': amount,
      'title': title,
      'category': category,
      'date': DateTime.now().toIso8601String(),
      'note': note,
    };

    final incomes = prefs.getStringList('user_incomes') ?? [];
    incomes.add(jsonEncode(incomeData));
    await prefs.setStringList('user_incomes', incomes);
  }

  // Add expense to tracker
  Future<void> _addExpense(double amount, String title, String category, String note) async {
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
      note: note,
    );

    await ExpenseTracker.addExpense(expense);
  }

  // Add goal to tracker
  Future<void> _addGoal(double amount, String title, String category, String note) async {
    final prefs = await SharedPreferences.getInstance();
    final goalData = {
      'amount': amount,
      'title': title,
      'category': category,
      'date': DateTime.now().toIso8601String(),
      'note': note,
      'progress': 0.0,
    };

    final goals = prefs.getStringList('user_goals') ?? [];
    goals.add(jsonEncode(goalData));
    await prefs.setStringList('user_goals', goals);
  }

  void _handleCommand(String command) async {
    String response = '';

    switch (command.toLowerCase()) {
      case '/spending-summary':
        response = await _getSpendingSummary();
        break;
      case '/goal-progress':
        response = await _getGoalProgress();
        break;
      case '/budget-tips':
        response = await _getBudgetTips();
        break;
      case '/help':
        response = _getHelpMessage();
        break;
      default:
        response = "Girl, I don't know that command! 😅 Try '/help' to see what I can do!";
    }

    _addMaliResponse(response);
  }

  Future<String> _getSpendingSummary() async {
    final greeting = _userProfile?.genderGreeting ?? 'Girl';
    final currentMonth = DateTime.now();
    final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
    final totalSpending = spendingInsights['total_spending'] ?? 0.0;
    final topCategory = spendingInsights['top_category'] ?? '';
    final topAmount = spendingInsights['top_amount'] ?? 0.0;
    final averageDaily = spendingInsights['average_daily'] ?? 0.0;
    final categoryBreakdown = spendingInsights['category_breakdown'] ?? {};

    String breakdown = '';
    categoryBreakdown.forEach((category, amount) {
      breakdown += '• $category: KSh ${amount.toStringAsFixed(0)}\n';
    });

    String advice = '';
    if (topAmount > 10000) {
      advice = '\n\n💡 **Mali\'s Advice:** Your biggest expense is $topCategory at KSh ${topAmount.toStringAsFixed(0)}. Consider setting a budget for this category!';
    } else if (averageDaily > 2000) {
      advice = '\n\n💡 **Mali\'s Advice:** Your daily spending is KSh ${averageDaily.toStringAsFixed(0)}. Try to reduce it to save more!';
    } else {
      advice = '\n\n💡 **Mali\'s Advice:** Your spending looks good! Keep tracking to stay on top of your finances!';
    }

    return "$greeting, here's your spending summary for this month! 💰\n\n📊 **This Month's Spending:**\n$breakdown\n💰 **Total: KSh ${totalSpending.toStringAsFixed(0)}**\n📈 **Daily Average: KSh ${averageDaily.toStringAsFixed(0)}**$advice";
  }

  Future<String> _getGoalProgress() async {
    final greeting = _userProfile?.genderGreeting ?? 'Girl';
    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getStringList('user_goals') ?? [];
    
    if (goalsString.isEmpty) {
      return "$greeting, you haven't set any financial goals yet! 🎯\n\n💡 **Set your first goal:**\n• Emergency Fund: 3-6 months of expenses\n• Vacation Fund: Save for your dream trip\n• Investment Fund: Start building wealth\n\nJust tell me: \"I want to save [amount] for [goal]\"!";
    }

    String goalsList = '';
    double totalGoals = 0;
    for (final goalString in goalsString) {
      final goalData = jsonDecode(goalString);
      final amount = goalData['amount'];
      final title = goalData['title'];
      totalGoals += amount;
      goalsList += '• $title: KSh ${amount.toStringAsFixed(0)}\n';
    }

    // Calculate progress based on current savings
    final currentMonth = DateTime.now();
    final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
    final totalSpending = spendingInsights['total_spending'] ?? 0.0;
    
    final prefs2 = await SharedPreferences.getInstance();
    final incomesString = prefs2.getStringList('user_incomes') ?? [];
    double totalIncome = 0;
    for (final incomeString in incomesString) {
      final incomeData = jsonDecode(incomeString);
      final incomeDate = DateTime.parse(incomeData['date']);
      if (incomeDate.year == currentMonth.year && incomeDate.month == currentMonth.month) {
        totalIncome += incomeData['amount'];
      }
    }
    
    final currentSavings = totalIncome - totalSpending;
    final progressPercentage = totalGoals > 0 ? (currentSavings / totalGoals * 100).clamp(0.0, 100.0) : 0.0;

    return "$greeting, here's your goal progress! 🎯\n\n📋 **Your Financial Goals:**\n$goalsList\n💰 **Total Goal Amount: KSh ${totalGoals.toStringAsFixed(0)}**\n💪 **Current Savings: KSh ${currentSavings.toStringAsFixed(0)}**\n📊 **Progress: ${progressPercentage.toStringAsFixed(1)}%**\n\nKeep pushing, girl! Every shilling counts! 💪";
  }

  Future<String> _getBudgetTips() async {
    final greeting = _userProfile?.genderGreeting ?? 'Girl';
    final currentMonth = DateTime.now();
    final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
    final totalSpending = spendingInsights['total_spending'] ?? 0.0;
    final topCategory = spendingInsights['top_category'] ?? '';
    final topAmount = spendingInsights['top_amount'] ?? 0.0;

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

    final savings = totalIncome - totalSpending;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome * 100) : 0.0;

    String personalizedTips = '';
    
    if (savingsRate < 10) {
      personalizedTips = '💡 **Priority Tips:**\n• Track every expense (even small ones)\n• Use the 50/30/20 rule: 50% needs, 30% wants, 20% savings\n• Cook at home more often\n• Use public transport when possible';
    } else if (savingsRate < 20) {
      personalizedTips = '💡 **Good Progress Tips:**\n• Try to increase savings to 20%\n• Set up automatic transfers to savings\n• Review your biggest expenses\n• Consider investing your savings';
    } else {
      personalizedTips = '💡 **Excellent Tips:**\n• You\'re doing amazing! Keep it up!\n• Consider investing your savings\n• Set up an emergency fund\n• Start planning for long-term goals';
    }

    String categoryTips = '';
    if (topAmount > 10000) {
      categoryTips = '\n\n🎯 **Focus on $topCategory:**\n• Set a monthly budget for $topCategory\n• Look for ways to reduce $topCategory spending\n• Consider alternatives for $topCategory expenses';
    }

    return "$greeting, here are your personalized budget tips! 💡\n\n📊 **Your Current Status:**\n• Income: KSh ${totalIncome.toStringAsFixed(0)}\n• Spending: KSh ${totalSpending.toStringAsFixed(0)}\n• Savings Rate: ${savingsRate.toStringAsFixed(1)}%\n\n$personalizedTips$categoryTips\n\nRemember, every shilling counts! 💪";
  }

  String _getHelpMessage() {
    return "Here are the commands I understand, girl! 💅\n\n📋 **Available Commands:**\n• `/spending-summary` - Get your spending breakdown\n• `/goal-progress` - Check your financial goals\n• `/budget-tips` - Get personalized budget advice\n• `/help` - Show this help message\n\n💬 **Or just chat with me normally!**\n\nTry asking me anything about your money! 💰";
  }

  void _addMaliResponse(String userMessage) async {
    String response = await _getSophisticatedMaliResponse(userMessage);
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isFromUser: false,
            timestamp: DateTime.now(),
          ));
        });
        
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }

  Future<String> _getSophisticatedMaliResponse(String message) async {
    try {
      // Get real financial data
      final financialData = await FinancialDataService.getComprehensiveFinancialData();
      
      // Try AI service first
      final aiResponse = await AIService.getPersonalizedAdvice(
        userMessage: message,
        userProfile: _userProfile,
        financialData: financialData,
      );
      
      return aiResponse;
    } catch (e) {
      // Fallback to local responses if AI fails
      return _getFallbackResponse(message, _userProfile, {});
    }
  }

  String _getFallbackResponse(String userMessage, UserProfile? userProfile, Map<String, dynamic> financialData) {
    final lowerMessage = userMessage.toLowerCase();
    final greeting = userProfile?.genderGreeting ?? 'Hey';
    final pronoun = userProfile?.genderPronoun ?? 'sister';

    if (lowerMessage.contains('spend') || lowerMessage.contains('bought') || 
        lowerMessage.contains('coffee') || lowerMessage.contains('uber') || 
        lowerMessage.contains('food') || lowerMessage.contains('shop')) {
      return "$greeting, I see you're spending money! 💰 Let me help you track that and maybe find ways to save more! 💡";
    }

    // Saving responses
    if (lowerMessage.contains('save') || lowerMessage.contains('saving')) {
      return "$greeting, that's what I like to hear! 💪 Saving money is the key to financial freedom! Let's set some goals together! 🎯";
    }

    // Goal responses
    if (lowerMessage.contains('goal') || lowerMessage.contains('target')) {
      return "$greeting, goals are everything! 🎯 What do you want to achieve? A new phone? Vacation? Emergency fund? Tell me and I'll help you get there! ✨";
    }

    // Income responses
    if (lowerMessage.contains('salary') || lowerMessage.contains('income') || lowerMessage.contains('money')) {
      return "$greeting, money coming in! 💰 That's what I like to hear! How are you planning to use it? Let's make sure you're not just spending it all! 💅";
    }

    // Budget responses
    if (lowerMessage.contains('budget') || lowerMessage.contains('limit')) {
      return "$greeting, budgeting is your best friend! 💡 Start by tracking your expenses, then create a realistic budget. I'm here to help! 📊";
    }

    // Financial education responses
    if (lowerMessage.contains('invest') || lowerMessage.contains('emergency') || 
        lowerMessage.contains('debt') || lowerMessage.contains('sacco') || 
        lowerMessage.contains('chama') || lowerMessage.contains('m-pesa')) {
      return "$greeting, let's talk financial education! 📚 I can help you with investing, emergency funds, debt management, and more! What interests you? 💡";
    }

    // Greeting responses
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('hey')) {
      return "$greeting! 👋 I'm Mali, your financial big $pronoun! How can I help you with your money today? 💰";
    }

    // Help responses
    if (lowerMessage.contains('help') || lowerMessage.contains('advice')) {
      return "$greeting, of course I'll help you! 💁‍♀️ I'm your financial big $pronoun, remember? What do you need advice on? 💡";
    }

    // Default response
    return "$greeting, I'm here to help you with all things money! 💰 Whether it's spending, saving, budgeting, or investing - just ask! 💪";
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: "${_userProfile?.genderGreeting ?? 'Hey'}! 👋 I'm Mali, your financial big ${_userProfile?.genderPronoun ?? 'sister'}! How can I help you with your money today? 💰\n\n💡 **Quick Commands:**\n• `/spending-summary` - Get spending breakdown\n• `/goal-progress` - Check your goals\n• `/budget-tips` - Get budget advice\n• `/help` - Show all commands\n\n💬 **Or just chat with me normally!**\n\nTry telling me about your income or expenses!",
      isFromUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _addUserMessage(String message) {
    _messages.add(ChatMessage(
      text: message,
      isFromUser: true,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mali',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Your Financial Big Sister',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isFromUser ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isFromUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
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
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Talk to Mali...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
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