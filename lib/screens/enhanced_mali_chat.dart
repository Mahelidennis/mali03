import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../mali_chat_enhanced.dart';

class EnhancedMaliChat extends StatefulWidget {
  const EnhancedMaliChat({super.key});

  @override
  State<EnhancedMaliChat> createState() => _EnhancedMaliChatState();
}

class _EnhancedMaliChatState extends State<EnhancedMaliChat>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Map<String, dynamic> _financialData = {};
  String _selectedVibe = 'Sassy & Bold';
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadFinancialData();
    _loadUserVibe();
    _addWelcomeMessage();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFinancialData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final incomesString = prefs.getStringList('user_incomes') ?? [];
    final expensesString = prefs.getStringList('user_expenses') ?? [];
    final budgetsString = prefs.getStringList('user_budgets') ?? [];
    final goalsString = prefs.getStringList('user_goals') ?? [];
    
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
        "Welcome! 🌺 I'm here to help you build a brighter financial future with kindness and understanding.",
      ],
      'Professional & Direct': [
        "Good day! I'm Mali, your financial AI assistant. I'm here to provide expert guidance on your financial matters.",
        "Hello! I'm ready to help you optimize your financial strategy and achieve your goals efficiently.",
        "Welcome! I'm Mali, your dedicated financial advisor. Let's work together to improve your financial health.",
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

  void _sendMessage() {
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

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      _generateAIResponse(text);
    });
  }

  void _generateAIResponse(String userMessage) {
    final responses = {
      'Sassy & Bold': [
        "Honey, that's a great question! 💅 Let me break it down for you...",
        "Ooh, I love where your head's at! 💖 Here's what I think...",
        "Girl, you're asking all the right questions! 🔥 Let me help you out...",
        "Babe, I've got you covered! 💪 Here's the tea...",
      ],
      'Encouraging & Gentle': [
        "That's a wonderful question! 🌸 Let me help you understand...",
        "I'm so glad you asked! 💙 Here's what I can tell you...",
        "That's a great way to think about it! 🌺 Let me explain...",
        "I'm here to help! 💕 Here's my perspective...",
      ],
      'Professional & Direct': [
        "Excellent question. Let me provide you with a comprehensive answer...",
        "I understand your concern. Here's my analysis...",
        "That's an important consideration. Let me explain...",
        "I'll help you with that. Here's what you need to know...",
      ],
    };

    final responseTemplates = responses[_selectedVibe] ?? responses['Sassy & Bold']!;
    final randomResponse = responseTemplates[Random().nextInt(responseTemplates.length)];

    final aiResponse = "$randomResponse\n\nBased on your financial data, I can see you have some great opportunities to optimize your money management. Would you like me to analyze your spending patterns or help you set up a budget?";

    setState(() {
      _messages.add(ChatMessage(
        text: aiResponse,
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: 'advice',
      ));
      _isLoading = false;
    });

    _scrollToBottom();
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
      backgroundColor: const Color(0xFFFDF2F8),
      body: Column(
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEE2B8D),
                  const Color(0xFFEE2B8D).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEE2B8D).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Mali Avatar with Animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.psychology,
                          size: 40,
                          color: Color(0xFFEE2B8D),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Mali Name and Status
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Mali',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Online',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Personal Financial AI Assistant',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Chat Messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildLoadingMessage();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F0F2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ask Mali anything about your finances...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEE2B8D), Color(0xFFEE2B8D)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEE2B8D).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEE2B8D).withOpacity(0.1),
                  const Color(0xFFEE2B8D).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Color(0xFFEE2B8D),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start a conversation with Mali',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181114),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about your finances, budgeting, or financial goals!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEE2B8D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: Color(0xFFEE2B8D),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F0F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFEE2B8D).withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mali is thinking...',
                  style: TextStyle(
                    color: Colors.grey[600],
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

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEE2B8D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Color(0xFFEE2B8D),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isFromUser
                    ? const Color(0xFFEE2B8D)
                    : const Color(0xFFF4F0F2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isFromUser ? Colors.white : const Color(0xFF181114),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isFromUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEE2B8D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFFEE2B8D),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
