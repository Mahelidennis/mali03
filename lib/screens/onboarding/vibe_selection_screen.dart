import 'package:flutter/material.dart';
import '../../models/onboarding_models.dart';
import '../../services/onboarding_service.dart';

class VibeSelectionScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const VibeSelectionScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<VibeSelectionScreen> createState() => _VibeSelectionScreenState();
}

class _VibeSelectionScreenState extends State<VibeSelectionScreen> {
  List<MaliVibe> _vibes = [];
  String? _selectedVibeId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVibes();
  }

  void _loadVibes() {
    setState(() {
      _vibes = OnboardingService.instance.getAvailableVibes();
    });
  }

  Future<void> _handleContinue() async {
    if (_selectedVibeId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await OnboardingService.instance.selectVibe(_selectedVibeId!);
      widget.onComplete();
    } catch (e) {
      print('Error selecting vibe: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildVibeCard(MaliVibe vibe) {
    final isSelected = _selectedVibeId == vibe.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVibeId = vibe.id;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDF2F8) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFEE2B8D) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: vibe.color == 'purple' 
                    ? const Color(0xFF8B5CF6) 
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  vibe.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Vibe details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vibe.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181114),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vibe.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEE2B8D) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFEE2B8D) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF181114),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Set Your Vibe',
          style: TextStyle(
            color: Color(0xFF181114),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Progress indicator
              Container(
                width: 60,
                height: 4,
                margin: const EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFFEE2B8D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Main heading
              const Text(
                'Choose your vibe',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181114),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Description
              const Text(
                'How do you want Mali to talk to you? Pick a vibe that suits your style.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF181114),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Vibe options
              Expanded(
                child: ListView.builder(
                  itemCount: _vibes.length,
                  itemBuilder: (context, index) {
                    return _buildVibeCard(_vibes[index]);
                  },
                ),
              ),
              
              // Continue button
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedVibeId != null && !_isLoading ? _handleContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE2B8D),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
