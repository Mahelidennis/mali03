import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'permissions_privacy_screen.dart';

class UserProfileSetupScreen extends StatefulWidget {
  const UserProfileSetupScreen({super.key});

  @override
  State<UserProfileSetupScreen> createState() => _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState extends State<UserProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String? _selectedAgeRange;
  String? _selectedOccupation;
  String? _selectedIncomeRange;
  List<String> _selectedGoals = [];
  
  final List<String> _ageRanges = [
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55-64',
    '65+',
  ];
  
  final List<String> _occupations = [
    'Student',
    'Employed',
    'Self-employed',
    'Freelancer',
    'Entrepreneur',
    'Retired',
    'Unemployed',
    'Other',
  ];
  
  final List<String> _incomeRanges = [
    'Under 20,000 KES',
    '20,000 - 50,000 KES',
    '50,000 - 100,000 KES',
    '100,000 - 200,000 KES',
    '200,000 - 500,000 KES',
    '500,000+ KES',
  ];
  
  final List<String> _financialGoals = [
    'Saving for a home',
    'Education',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAgeRange == null || _selectedOccupation == null || _selectedIncomeRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_setup_complete', true);
    
    // Save profile data
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('age_range', _selectedAgeRange!);
    await prefs.setString('occupation', _selectedOccupation!);
    await prefs.setString('income_range', _selectedIncomeRange!);
    await prefs.setStringList('financial_goals', _selectedGoals);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PermissionsPrivacyScreen()),
      );
    }
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEE2B8D), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
        ),
      ],
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile Setup',
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
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Step 2 of 3',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 2/3, // 2 out of 3 steps
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEE2B8D)),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    
                    // Full Name field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your full name',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEE2B8D), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Age Range dropdown
                    _buildDropdown(
                      label: 'Age Range',
                      value: _selectedAgeRange,
                      items: _ageRanges,
                      onChanged: (value) {
                        setState(() {
                          _selectedAgeRange = value;
                        });
                      },
                      placeholder: 'Select age range',
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Occupation dropdown
                    _buildDropdown(
                      label: 'Occupation',
                      value: _selectedOccupation,
                      items: _occupations,
                      onChanged: (value) {
                        setState(() {
                          _selectedOccupation = value;
                        });
                      },
                      placeholder: 'Select occupation',
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Income Range dropdown
                    _buildDropdown(
                      label: 'Income Range (Monthly, KES)',
                      value: _selectedIncomeRange,
                      items: _incomeRanges,
                      onChanged: (value) {
                        setState(() {
                          _selectedIncomeRange = value;
                        });
                      },
                      placeholder: 'Select income range',
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Primary Financial Goals section
                    const Text(
                      'Primary Financial Goals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tell us what you\'re working towards. You can select multiple.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Financial goals checkboxes
                    ..._financialGoals.map((goal) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CheckboxListTile(
                          title: Text(
                            goal,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          value: _selectedGoals.contains(goal),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedGoals.add(goal);
                              } else {
                                _selectedGoals.remove(goal);
                              }
                            });
                          },
                          activeColor: const Color(0xFFEE2B8D),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          
          // Complete Setup button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _completeSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE2B8D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Complete Setup',
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
