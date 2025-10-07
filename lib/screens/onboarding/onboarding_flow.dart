import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'vibe_selection_screen.dart';
import 'permissions_screen.dart';
import '../../services/onboarding_service.dart';

class OnboardingFlow extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingFlow({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onComplete();
    }
  }

  Widget _getCurrentScreen() {
    switch (_currentStep) {
      case 0:
        return WelcomeScreen(onComplete: _nextStep);
      case 1:
        return VibeSelectionScreen(onComplete: _nextStep);
      case 2:
        return PermissionsScreen(onComplete: widget.onComplete);
      default:
        return WelcomeScreen(onComplete: _nextStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          setState(() {
            _currentStep--;
          });
          return false;
        }
        return true;
      },
      child: _getCurrentScreen(),
    );
  }
}

class OnboardingWrapper extends StatefulWidget {
  final Widget child;

  const OnboardingWrapper({
    super.key,
    required this.child,
  });

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  bool _isOnboardingComplete = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final isComplete = await OnboardingService.instance.isOnboardingComplete();
      setState(() {
        _isOnboardingComplete = isComplete;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking onboarding status: $e');
      setState(() {
        _isOnboardingComplete = false;
        _isLoading = false;
      });
    }
  }

  void _onOnboardingComplete() {
    setState(() {
      _isOnboardingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE2B8D)),
          ),
        ),
      );
    }

    if (!_isOnboardingComplete) {
      return OnboardingFlow(onComplete: _onOnboardingComplete);
    }

    return widget.child;
  }
}
