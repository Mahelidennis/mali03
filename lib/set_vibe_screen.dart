import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile_setup_screen.dart';

class SetVibeScreen extends StatefulWidget {
  const SetVibeScreen({super.key});

  @override
  State<SetVibeScreen> createState() => _SetVibeScreenState();
}

class _SetVibeScreenState extends State<SetVibeScreen> {
  String _selectedVibe = '';
  
  final List<Map<String, String>> _vibeOptions = [
    {
      'title': 'Sassy & Bold',
      'emoji': '👩‍🦱',
      'description': 'Your hype-woman for all things money.',
    },
    {
      'title': 'Encouraging & Gentle',
      'emoji': '😇',
      'description': 'A soft nudge in the right direction.',
    },
    {
      'title': 'No-Nonsense & Direct',
      'emoji': '😤',
      'description': 'Just the facts, straight up.',
    },
  ];

  Future<void> _completeVibeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibe_setup_complete', true);
    await prefs.setString('selected_vibe', _selectedVibe);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserProfileSetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Set Your Vibe',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: LinearProgressIndicator(
              value: 0.5, // Half progress
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEE2B8D)),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 40),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your vibe',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How do you want Mali to talk to you? Pick a vibe that suits your style.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Vibe options
                  Expanded(
                    child: ListView.builder(
                      itemCount: _vibeOptions.length,
                      itemBuilder: (context, index) {
                        final vibe = _vibeOptions[index];
                        final isSelected = _selectedVibe == vibe['title'];
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedVibe = vibe['title']!;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected 
                                      ? const Color(0xFFEE2B8D)
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    vibe['emoji']!,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vibe['title']!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected 
                                                ? const Color(0xFFEE2B8D)
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          vibe['description']!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Radio<String>(
                                    value: vibe['title']!,
                                    groupValue: _selectedVibe,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedVibe = value!;
                                      });
                                    },
                                    activeColor: const Color(0xFFEE2B8D),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Continue button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedVibe.isNotEmpty ? _completeVibeSetup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE2B8D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
