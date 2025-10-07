import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_models.dart';

class OnboardingService {
  static const String _onboardingKey = 'mali_onboarding_state';
  static const String _vibesKey = 'mali_available_vibes';

  // Available Mali vibes
  static const List<MaliVibe> _defaultVibes = [
    MaliVibe(
      id: 'sassy_bold',
      title: 'Sassy & Bold',
      description: 'Your hype-woman for all things money.',
      emoji: '💁‍♀️',
      color: 'purple',
    ),
    MaliVibe(
      id: 'encouraging_gentle',
      title: 'Encouraging & Gentle',
      description: 'A soft nudge in the right direction.',
      emoji: '😊',
      color: 'yellow',
    ),
    MaliVibe(
      id: 'no_nonsense_direct',
      title: 'No-Nonsense & Direct',
      description: 'Just the facts, straight up.',
      emoji: '😠',
      color: 'yellow',
    ),
  ];

  static OnboardingService? _instance;
  static OnboardingService get instance {
    _instance ??= OnboardingService._();
    return _instance!;
  }

  OnboardingService._();

  // Get current onboarding state
  Future<OnboardingState> getOnboardingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_onboardingKey);
      
      if (stateJson != null) {
        final stateMap = json.decode(stateJson);
        return OnboardingState.fromJson(stateMap);
      }
      
      return const OnboardingState();
    } catch (e) {
      print('Error getting onboarding state: $e');
      return const OnboardingState();
    }
  }

  // Save onboarding state
  Future<bool> saveOnboardingState(OnboardingState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = json.encode(state.toJson());
      return await prefs.setString(_onboardingKey, stateJson);
    } catch (e) {
      print('Error saving onboarding state: $e');
      return false;
    }
  }

  // Get available vibes
  List<MaliVibe> getAvailableVibes() {
    return List.from(_defaultVibes);
  }

  // Get vibe by ID
  MaliVibe? getVibeById(String id) {
    try {
      return _defaultVibes.firstWhere((vibe) => vibe.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update selected vibe
  Future<bool> selectVibe(String vibeId) async {
    try {
      final currentState = await getOnboardingState();
      final updatedState = currentState.copyWith(selectedVibeId: vibeId);
      return await saveOnboardingState(updatedState);
    } catch (e) {
      print('Error selecting vibe: $e');
      return false;
    }
  }

  // Complete welcome screen
  Future<bool> completeWelcome() async {
    try {
      final currentState = await getOnboardingState();
      final updatedState = currentState.copyWith(hasCompletedWelcome: true);
      return await saveOnboardingState(updatedState);
    } catch (e) {
      print('Error completing welcome: $e');
      return false;
    }
  }

  // Accept permissions
  Future<bool> acceptPermissions() async {
    try {
      final currentState = await getOnboardingState();
      final updatedState = currentState.copyWith(hasAcceptedPermissions: true);
      return await saveOnboardingState(updatedState);
    } catch (e) {
      print('Error accepting permissions: $e');
      return false;
    }
  }

  // Complete onboarding
  Future<bool> completeOnboarding() async {
    try {
      final currentState = await getOnboardingState();
      final updatedState = currentState.copyWith(hasCompletedOnboarding: true);
      return await saveOnboardingState(updatedState);
    } catch (e) {
      print('Error completing onboarding: $e');
      return false;
    }
  }

  // Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    try {
      final state = await getOnboardingState();
      return state.hasCompletedOnboarding;
    } catch (e) {
      print('Error checking onboarding completion: $e');
      return false;
    }
  }

  // Reset onboarding (for testing or re-onboarding)
  Future<bool> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
      return true;
    } catch (e) {
      print('Error resetting onboarding: $e');
      return false;
    }
  }

  // Get user's selected vibe
  Future<MaliVibe?> getUserSelectedVibe() async {
    try {
      final state = await getOnboardingState();
      if (state.selectedVibeId != null) {
        return getVibeById(state.selectedVibeId!);
      }
      return null;
    } catch (e) {
      print('Error getting user selected vibe: $e');
      return null;
    }
  }
}
