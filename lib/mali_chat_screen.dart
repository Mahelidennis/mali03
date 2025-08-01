import 'package:flutter/material.dart';
import 'user_profile.dart';
import 'mali_ai_service.dart';

class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final bool isCommand;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.isCommand = false,
  });
}

class MaliChatScreen extends StatefulWidget {
  const MaliChatScreen({super.key});

  @override
  State<MaliChatScreen> createState() => _MaliChatScreenState();
}

class _MaliChatScreenState extends State<MaliChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  UserProfile? _userProfile;

  // Custom commands
  final Map<String, String> _commands = {
    '/spending-summary': 'Get your spending summary for this month',
    '/goal-progress': 'Check your financial goals progress',
    '/budget-tips': 'Get personalized budget tips from Mali',
    '/help': 'Show available commands',
  };

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _addWelcomeMessage();
  }

  Future<void> _loadUserProfile() async {
    final profile = await UserProfileManager.getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  void _addWelcomeMessage() {
    final greeting = _userProfile?.genderGreeting ?? 'Hey';
    final pronoun = _userProfile?.genderPronoun ?? 'sister';
    
    _messages.add(ChatMessage(
      text: "$greeting! 👋 I'm Mali, your financial big $pronoun! 💅\n\nI'm here to help you with:\n• Spending analysis 💰\n• Goal tracking 🎯\n• Budget tips 💡\n• Financial advice 💪\n\nTry typing '/help' to see all commands!",
      isFromUser: false,
      timestamp: DateTime.now(),
    ));
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
      isCommand: isCommand,
    ));

    setState(() {
      _messageController.clear();
    });

    // Handle command or get AI response
    if (isCommand) {
      _handleCommand(message);
    } else {
      _getAIResponse(message);
    }

    _scrollToBottom();
  }

  void _handleCommand(String command) {
    String response = '';

    switch (command.toLowerCase()) {
      case '/spending-summary':
        response = MaliAIService.getSpendingSummary(_userProfile);
        break;
      case '/goal-progress':
        response = MaliAIService.getGoalProgress(_userProfile);
        break;
      case '/budget-tips':
        response = MaliAIService.getBudgetTips(_userProfile);
        break;
      case '/help':
        response = MaliAIService.getHelpMessage();
        break;
      default:
        response = "Girl, I don't know that command! 😅 Try '/help' to see what I can do!";
    }

    _addMaliResponse(response);
  }

  void _getAIResponse(String userMessage) {
    setState(() {
      _isLoading = true;
    });

    // Quick response
    Future.delayed(const Duration(milliseconds: 300), () {
      final response = MaliAIService.getMaliResponse(
        userMessage: userMessage,
        userProfile: _userProfile,
      );
      
      _addMaliResponse(response);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _addMaliResponse(String response) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isFromUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
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
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple,
              child: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Mali',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Mali is typing...'),
                ],
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isFromUser;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.purple,
              child: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.purple : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ],
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
            blurRadius: 4,
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
                hintText: 'Ask Mali anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: Colors.purple,
            mini: true,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
} 