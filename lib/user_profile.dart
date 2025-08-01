import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserGender { male, female, other }

class UserProfile {
  final String name;
  final UserGender gender;
  final double monthlyIncome;
  final List<String> interests;
  final DateTime joinDate;
  final String preferredLanguage; // 'en', 'sw', 'sh'
  final String primaryGoal;

  UserProfile({
    required this.name,
    required this.gender,
    required this.monthlyIncome,
    required this.interests,
    required this.joinDate,
    required this.preferredLanguage,
    required this.primaryGoal,
  });

  String get genderPronoun => gender == UserGender.female ? 'sister' : 'brother';
  String get genderEmoji => gender == UserGender.female ? '👧' : '👦';
  String get genderGreeting => gender == UserGender.female ? 'Girl' : 'Bro';
}

class UserProfileManager {
  static const String _nameKey = 'user_name';
  static const String _genderKey = 'user_gender';
  static const String _incomeKey = 'monthly_income';
  static const String _interestsKey = 'user_interests';
  static const String _joinDateKey = 'join_date';
  static const String _languageKey = 'preferred_language';
  static const String _goalKey = 'user_goal';

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    final name = prefs.getString(_nameKey);
    if (name == null) return null;
    
    final genderString = prefs.getString(_genderKey) ?? 'female';
    final gender = genderString == 'male' ? UserGender.male : UserGender.female;
    
    return UserProfile(
      name: name,
      gender: gender,
      monthlyIncome: prefs.getDouble(_incomeKey) ?? 45000.0,
      interests: prefs.getStringList(_interestsKey) ?? [],
      preferredLanguage: prefs.getString(_languageKey) ?? 'en',
      primaryGoal: prefs.getString(_goalKey) ?? 'Save money',
      joinDate: DateTime.now(),
    );
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_nameKey, profile.name);
    await prefs.setString(_genderKey, profile.gender.name);
    await prefs.setDouble(_incomeKey, profile.monthlyIncome);
    await prefs.setStringList(_interestsKey, profile.interests);
    await prefs.setString(_languageKey, profile.preferredLanguage);
    await prefs.setString(_goalKey, profile.primaryGoal);
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_genderKey);
    await prefs.remove(_incomeKey);
    await prefs.remove(_interestsKey);
    await prefs.remove(_joinDateKey);
    await prefs.remove(_languageKey);
    await prefs.remove(_goalKey);
  }
} 