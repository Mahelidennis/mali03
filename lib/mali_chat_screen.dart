import 'package:flutter/material.dart';
import 'mali_chat_enhanced.dart';

class MaliChatScreen extends StatefulWidget {
  const MaliChatScreen({super.key});

  @override
  State<MaliChatScreen> createState() => _MaliChatScreenState();
}

class _MaliChatScreenState extends State<MaliChatScreen> {
  @override
  Widget build(BuildContext context) {
    return const MaliChatEnhanced();
  }
}