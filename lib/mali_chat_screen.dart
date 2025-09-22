import 'package:flutter/material.dart';
import 'screens/enhanced_mali_chat.dart';

class MaliChatScreen extends StatefulWidget {
  const MaliChatScreen({super.key});

  @override
  State<MaliChatScreen> createState() => _MaliChatScreenState();
}

class _MaliChatScreenState extends State<MaliChatScreen> {
  @override
  Widget build(BuildContext context) {
    return const EnhancedMaliChat();
  }
}