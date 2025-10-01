import 'package:flutter/material.dart';
import '../services/financial_personality_service.dart';

class PersonalityAssessmentScreen extends StatefulWidget {
  const PersonalityAssessmentScreen({super.key});

  @override
  State<PersonalityAssessmentScreen> createState() => _PersonalityAssessmentScreenState();
}

class _PersonalityAssessmentScreenState extends State<PersonalityAssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentQuestion = 0;
  final List<String> _answers = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final questions = FinancialPersonalityService.getAssessmentQuestions();
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text('Financial Personality Assessment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF181114),
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
                      'Question ${_currentQuestion + 1} of ${questions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${((_currentQuestion + 1) / questions.length * 100).round()}%',
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
                  value: (_currentQuestion + 1) / questions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEE2B8D)),
                ),
              ],
            ),
          ),
          
          // Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestion = index;
                });
              },
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionCard(questions[index], index);
              },
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestion > 0)
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.grey[700],
                      elevation: 0,
                    ),
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox(width: 80),
                
                if (_currentQuestion < questions.length - 1)
                  ElevatedButton(
                    onPressed: _answers.length > _currentQuestion ? _nextQuestion : null,
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: _answers.length > _currentQuestion ? _completeAssessment : null,
                    child: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Complete Assessment'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
    final questionText = question['question'] as String;
    final options = question['options'] as Map<String, String>;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question
              Text(
                questionText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181114),
                ),
              ),
              const SizedBox(height: 24),
              
              // Options
              ...options.entries.map((entry) => _buildOptionButton(
                entry.key,
                entry.value,
                index,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String optionText, String personalityType, int questionIndex) {
    final isSelected = _answers.length > questionIndex && _answers[questionIndex] == optionText;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () => _selectAnswer(optionText, questionIndex),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFFEE2B8D) : Colors.white,
          foregroundColor: isSelected ? Colors.white : const Color(0xFF181114),
          elevation: isSelected ? 8 : 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? const Color(0xFFEE2B8D) : Colors.grey[300]!,
              width: 2,
            ),
          ),
        ),
        child: Text(
          optionText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  void _selectAnswer(String answer, int questionIndex) {
    setState(() {
      // Ensure answers list is long enough
      while (_answers.length <= questionIndex) {
        _answers.add('');
      }
      _answers[questionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < FinancialPersonalityService.getAssessmentQuestions().length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeAssessment() async {
    if (_answers.length < FinancialPersonalityService.getAssessmentQuestions().length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before completing the assessment.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate personality
      final personality = await FinancialPersonalityService.calculatePersonality(_answers);
      
      // Save personality
      await FinancialPersonalityService.savePersonality(personality);
      
      // Show results
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalityResultsScreen(personality: personality),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing assessment: $e'),
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
}

class PersonalityResultsScreen extends StatelessWidget {
  final FinancialPersonality personality;

  const PersonalityResultsScreen({
    super.key,
    required this.personality,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text('Your Financial Personality'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF181114),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personality Card
            Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Personality Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEE2B8D), Color(0xFFEE2B8D)],
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Personality Name
                    Text(
                      personality.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181114),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      personality.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Confidence Level
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEE2B8D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Confidence: ${(personality.confidence * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEE2B8D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Strengths
            _buildSectionCard(
              'Your Strengths',
              Icons.star,
              personality.strengths,
              Colors.green,
            ),
            
            const SizedBox(height: 16),
            
            // Challenges
            _buildSectionCard(
              'Areas to Focus On',
              Icons.trending_up,
              personality.challenges,
              Colors.orange,
            ),
            
            const SizedBox(height: 24),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continue to Mali Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<String> items, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181114),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
