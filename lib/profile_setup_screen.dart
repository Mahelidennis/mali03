import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedAgeRange = '';
  String _selectedOccupation = '';
  String _selectedIncomeRange = '';
  final List<String> _selectedGoals = [];

  final List<String> _ageRanges = [
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55+',
  ];

  final List<String> _occupations = [
    'Student',
    'Employed',
    'Self-employed',
    'Freelancer',
    'Unemployed',
    'Retired',
  ];

  final List<String> _incomeRanges = [
    '< 25,000',
    '25,000 - 50,000',
    '50,000 - 100,000',
    '100,000 - 200,000',
    '> 200,000',
  ];

  final List<String> _financialGoals = [
    'Saving for a home',
    'Education',
    'Starting a business',
    'Emergency fund',
    'Retirement',
    'Travel',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF181114)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile Setup',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF181114),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Step 2 of 3',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF575354),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.66,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF181114),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      hintText: 'Enter your full name',
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Age Range',
                      value: _selectedAgeRange,
                      items: _ageRanges,
                      onChanged: (value) => setState(() => _selectedAgeRange = value!),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Occupation',
                      value: _selectedOccupation,
                      items: _occupations,
                      onChanged: (value) => setState(() => _selectedOccupation = value!),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Income Range (Monthly, KES)',
                      value: _selectedIncomeRange,
                      items: _incomeRanges,
                      onChanged: (value) => setState(() => _selectedIncomeRange = value!),
                    ),
                    const SizedBox(height: 24),
                    _buildGoalsSection(),
                  ],
                ),
              ),
            ),
          ),
          // Complete button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              // backdropFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _completeSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE2B8D),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: const Color(0xFFEE2B8D).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Complete Setup',
                  style: TextStyle(
                    fontSize: 16,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF575354),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF575354)),
            filled: true,
            fillColor: const Color(0xFFF4F0F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEE2B8D), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF575354),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F0F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            hint: Text('Select $label'),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Primary Financial Goals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF181114),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tell us what you\'re working towards. You can select multiple.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF575354),
          ),
        ),
        const SizedBox(height: 16),
        ..._financialGoals.map((goal) => _buildGoalCheckbox(goal)),
      ],
    );
  }

  Widget _buildGoalCheckbox(String goal) {
    final isSelected = _selectedGoals.contains(goal);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedGoals.remove(goal);
            } else {
              _selectedGoals.add(goal);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFEE2B8D) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFEE2B8D).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEE2B8D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFEE2B8D) : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  goal,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? const Color(0xFFEE2B8D) : const Color(0xFF181114),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one financial goal'),
          backgroundColor: Color(0xFFEE2B8D),
        ),
      );
      return;
    }

    try {
      // Create user profile
      final profile = UserProfile(
        name: _nameController.text.trim(),
        gender: UserGender.female, // Default for now
        monthlyIncome: _parseIncome(_selectedIncomeRange),
        interests: _selectedGoals,
        joinDate: DateTime.now(),
        preferredLanguage: 'en',
        primaryGoal: _selectedGoals.first,
      );

      await UserProfileManager.saveUserProfile(profile);

      // Mark setup as complete
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('profile_setup_complete', true);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double _parseIncome(String incomeRange) {
    switch (incomeRange) {
      case '< 25,000':
        return 20000;
      case '25,000 - 50,000':
        return 37500;
      case '50,000 - 100,000':
        return 75000;
      case '100,000 - 200,000':
        return 150000;
      case '> 200,000':
        return 250000;
      default:
        return 0;
    }
  }
}
