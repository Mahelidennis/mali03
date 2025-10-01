import 'package:flutter/material.dart';
import '../services/emotional_therapy_service.dart';

class EmotionalTherapyScreen extends StatefulWidget {
  final EmotionalSession? session;
  
  const EmotionalTherapyScreen({
    super.key,
    this.session,
  });

  @override
  State<EmotionalTherapyScreen> createState() => _EmotionalTherapyScreenState();
}

class _EmotionalTherapyScreenState extends State<EmotionalTherapyScreen> {
  EmotionalSession? _currentSession;
  int _currentExercise = 0;
  bool _isLoading = false;
  double _effectiveness = 0.0;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSession == null) {
      return _buildSessionSelection();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text('Mali\'s Therapy Session'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF181114),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exercise ${_currentExercise + 1} of ${_currentSession!.exercises.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${((_currentExercise + 1) / _currentSession!.exercises.length * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFEE2B8D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_currentExercise + 1) / _currentSession!.exercises.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEE2B8D)),
                ),
              ],
            ),
          ),
          
          // Session content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session header
                  _buildSessionHeader(),
                  
                  const SizedBox(height: 24),
                  
                  // Current exercise
                  _buildCurrentExercise(),
                  
                  const SizedBox(height: 24),
                  
                  // Exercise navigation
                  _buildExerciseNavigation(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSelection() {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text('Emotional Therapy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF181114),
      ),
      body: Center(
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
                Icons.psychology,
                size: 60,
                color: Color(0xFFEE2B8D),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181114),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mali can help you work through your emotions and make better financial decisions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startNewSession,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Start Therapy Session',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionHeader() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mali avatar and title
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEE2B8D), Color(0xFFEE2B8D)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentSession!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF181114),
                        ),
                      ),
                      Text(
                        _getTherapyTypeText(_currentSession!.therapyType),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              _currentSession!.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF181114),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Duration
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  '${_currentSession!.duration} minutes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentExercise() {
    final exercise = _currentSession!.exercises[_currentExercise];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEE2B8D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${_currentExercise + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEE2B8D),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Exercise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181114),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              exercise,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF181114),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Exercise completion button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeCurrentExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE2B8D).withOpacity(0.1),
                  foregroundColor: const Color(0xFFEE2B8D),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFEE2B8D)),
                  ),
                ),
                child: const Text(
                  'I\'ve completed this exercise',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentExercise > 0)
          ElevatedButton(
            onPressed: _previousExercise,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.grey[700],
              elevation: 0,
            ),
            child: const Text('Previous'),
          )
        else
          const SizedBox(width: 80),
        
        if (_currentExercise < _currentSession!.exercises.length - 1)
          ElevatedButton(
            onPressed: _nextExercise,
            child: const Text('Next'),
          )
        else
          ElevatedButton(
            onPressed: _completeSession,
            child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Complete Session'),
          ),
      ],
    );
  }

  void _startNewSession() {
    // This would typically involve emotion detection
    // For now, we'll create a sample session
    final session = EmotionalSession(
      id: 'sample_session',
      detectedState: EmotionalState.stressed,
      therapyType: TherapyType.mindfulness,
      title: 'Let\'s Breathe Through This Together 💅',
      description: 'I know money stress can feel overwhelming. Let\'s take a moment to center ourselves and find some peace.',
      exercises: [
        'Take 5 deep breaths and imagine your stress floating away',
        'Write down 3 things you\'re grateful for right now',
        'Set a small, achievable financial goal for today',
        'Treat yourself to something free that brings you joy'
      ],
      context: {},
      createdAt: DateTime.now(),
      duration: 10,
    );
    
    setState(() {
      _currentSession = session;
    });
  }

  void _completeCurrentExercise() {
    // Move to next exercise
    if (_currentExercise < _currentSession!.exercises.length - 1) {
      setState(() {
        _currentExercise++;
      });
    }
  }

  void _nextExercise() {
    if (_currentExercise < _currentSession!.exercises.length - 1) {
      setState(() {
        _currentExercise++;
      });
    }
  }

  void _previousExercise() {
    if (_currentExercise > 0) {
      setState(() {
        _currentExercise--;
      });
    }
  }

  Future<void> _completeSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Show effectiveness rating dialog
      final effectiveness = await _showEffectivenessDialog();
      
      // Mark session as completed
      await EmotionalTherapyService.markSessionCompleted(
        _currentSession!.id,
        effectiveness,
      );
      
      // Show completion dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Session Complete! 🎉'),
            content: const Text('Great job working through your emotions! I\'m proud of you for taking care of your mental health.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close session
                },
                child: const Text('Thank you, Mali!'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<double> _showEffectivenessDialog() async {
    double effectiveness = 0.5;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('How helpful was this session?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rate the effectiveness: ${(effectiveness * 100).round()}%',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Slider(
                value: effectiveness,
                onChanged: (value) {
                  setState(() {
                    effectiveness = value;
                  });
                },
                min: 0.0,
                max: 1.0,
                divisions: 10,
                activeColor: const Color(0xFFEE2B8D),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Not helpful',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'Very helpful',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
    
    return effectiveness;
  }

  String _getTherapyTypeText(TherapyType type) {
    switch (type) {
      case TherapyType.mindfulness:
        return 'Mindfulness & Breathing';
      case TherapyType.cognitive:
        return 'Cognitive Therapy';
      case TherapyType.behavioral:
        return 'Behavioral Therapy';
      case TherapyType.emotional:
        return 'Emotional Processing';
      case TherapyType.motivational:
        return 'Motivational Therapy';
      case TherapyType.educational:
        return 'Educational Therapy';
      case TherapyType.supportive:
        return 'Supportive Therapy';
      case TherapyType.challenging:
        return 'Challenging Therapy';
    }
  }
}

