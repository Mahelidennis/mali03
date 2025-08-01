import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile.dart';
import 'main_app.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  UserGender _selectedGender = UserGender.female;
  double _monthlyIncome = 50000;
  String _primaryGoal = 'Save Money';
  bool _hasCompletedSignup = false;

  final List<String> _financialGoals = [
    'Save Money',
    'Pay Off Debt',
    'Invest',
    'Budget Better',
    'Emergency Fund',
    'Buy Property',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome to Mali! 👋',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let\'s get you set up with your financial big sister!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNameField(),
                          const SizedBox(height: 24),
                          _buildGenderSelection(),
                          const SizedBox(height: 24),
                          _buildIncomeField(),
                          const SizedBox(height: 24),
                          _buildGoalSelection(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  _buildSignupButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s your name?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How should I address you?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = UserGender.female),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedGender == UserGender.female
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedGender == UserGender.female
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text('👩', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        'Sister',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selectedGender == UserGender.female
                              ? Colors.purple
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'I\'ll be your financial big sister!',
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedGender == UserGender.female
                              ? Colors.purple.withOpacity(0.8)
                              : Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = UserGender.male),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedGender == UserGender.male
                        ? Colors.blue
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedGender == UserGender.male
                          ? Colors.blue
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text('👨', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        'Brother',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selectedGender == UserGender.male
                              ? Colors.white
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'I\'ll be your financial big brother!',
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedGender == UserGender.male
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s your monthly income?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Text(
                'KSh ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: TextFormField(
                  initialValue: _monthlyIncome.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '50000',
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _monthlyIncome = double.tryParse(value) ?? 50000;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s your main financial goal?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _primaryGoal,
              dropdownColor: Colors.purple,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: _financialGoals.map((String goal) {
                return DropdownMenuItem<String>(
                  value: goal,
                  child: Text(goal),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _primaryGoal = newValue!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.purple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Get Started with Mali!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      // Save user profile
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_onboarding_complete', true);
      
      // Create and save user profile
      final userProfile = UserProfile(
        name: _nameController.text.trim(),
        gender: _selectedGender,
        monthlyIncome: _monthlyIncome,
        primaryGoal: _primaryGoal,
        preferredLanguage: 'en',
        interests: [],
        joinDate: DateTime.now(),
      );

      // Save profile data (simplified for now)
      await prefs.setString('user_name', userProfile.name);
      await prefs.setString('user_gender', userProfile.gender.name);
      await prefs.setDouble('user_income', userProfile.monthlyIncome);
      await prefs.setString('user_goal', userProfile.primaryGoal);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainApp()),
        );
      }
    }
  }
} 