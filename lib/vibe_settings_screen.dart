import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VibeSettingsScreen extends StatefulWidget {
  const VibeSettingsScreen({super.key});

  @override
  State<VibeSettingsScreen> createState() => _VibeSettingsScreenState();
}

class _VibeSettingsScreenState extends State<VibeSettingsScreen> {
  String _selectedVibe = '';
  bool _isLoading = true;
  bool _isSaving = false;
  
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

  @override
  void initState() {
    super.initState();
    _loadCurrentVibe();
  }

  Future<void> _loadCurrentVibe() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVibe = prefs.getString('selected_vibe') ?? '';
    
    setState(() {
      _selectedVibe = currentVibe;
      _isLoading = false;
    });
  }

  Future<void> _saveVibe() async {
    if (_selectedVibe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vibe'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_vibe', _selectedVibe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vibe updated successfully!'),
            backgroundColor: Color(0xFFEE2B8D),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating vibe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Mali\'s Vibe',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveVibe,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE2B8D)),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFFEE2B8D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Choose your vibe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'How do you want Mali to talk to you? Pick a vibe that suits your style.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Vibe Options
                  ..._vibeOptions.map((vibe) {
                    final isSelected = _selectedVibe == vibe['title'];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedVibe = vibe['title']!;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFFEE2B8D)
                                  : Colors.grey[800]!,
                              width: isSelected ? 2 : 1,
                            ),
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
                                            : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      vibe['description']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
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
                  }).toList(),
                  
                  const SizedBox(height: 40),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveVibe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEE2B8D),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Vibe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
