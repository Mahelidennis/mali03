import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_app.dart';
import 'user_onboarding_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:math' as math;

class OnboardingPageData {
  final Color color;
  final String title;
  final String description;
  final String imageAsset;
  final String imageSemanticLabel;

  OnboardingPageData({
    required this.color,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.imageSemanticLabel,
  });
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnim;

  @override
  void initState() {
    super.initState();
    // _pages will be initialized in build to access context/localizations
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
    _buttonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _buttonScaleAnim = CurvedAnimation(
      parent: _buttonAnimController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    _buttonAnimController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete?.call(); // Analytics or setup callback
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserOnboardingScreen()),
      );
    }
  }

  void _handleNavigation({bool skip = false}) async {
    if (skip || _currentPage == 2) { // Fixed: hardcoded to 3 pages
      await _completeOnboarding();
    } else {
      _nextPage();
    }
  }

  List<List<Color>> get _gradients => [
    [const Color(0xFF7F53AC), const Color(0xFF647DEE)], // Purple-Blue
    [const Color(0xFF43CEA2), const Color(0xFF185A9D)], // Green-Blue
    [const Color(0xFFFF512F), const Color(0xFFDD2476)], // Orange-Pink
  ];

  Widget _buildPage(OnboardingPageData data, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final imageHeight = isWide ? 300.0 : 200.0;
        final padding = isWide ? 64.0 : 32.0;
        return AnimatedBuilder(
          animation: _fadeAnim,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnim.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradients[index % _gradients.length],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Image.asset(
                          data.imageAsset,
                          height: imageHeight,
                          semanticLabel: data.imageSemanticLabel,
                        ),
                      ),
                    ),
          const SizedBox(height: 32),
          Text(
                      data.title,
                      style: TextStyle(
                        fontSize: isWide ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 8,
                          ),
                        ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
                      data.description,
                      style: TextStyle(
                        fontSize: isWide ? 22 : 18,
              color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            ),
        ],
      ),
              ),
            );
          },
        );
      },
    );
  }

  void _nextPage() {
    if (_currentPage < 2) { // Fixed: hardcoded to 3 pages
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final List<OnboardingPageData> _pages = [
      OnboardingPageData(
        color: Colors.deepPurple,
        title: 'Track Your Finances',
        description: 'Monitor your spending and income effortlessly.',
        imageAsset: 'lib/assets/finance.png',
        imageSemanticLabel: 'Finance illustration',
      ),
      OnboardingPageData(
        color: Colors.indigo,
        title: 'Set Smart Goals',
        description: 'Plan and achieve your financial goals step by step.',
        imageAsset: 'lib/assets/goals.png',
        imageSemanticLabel: 'Goals illustration',
      ),
      OnboardingPageData(
        color: Colors.blue,
        title: 'Grow with AI',
        description: 'Let AI guide you to a healthier financial life.',
        imageAsset: 'lib/assets/ai.png',
        imageSemanticLabel: 'AI assistant illustration',
      ),
    ];
    final isLastPage = _currentPage == 2; // Fixed: hardcoded to 3 pages
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
                _animController.reset();
                _animController.forward();
              });
            },
            itemBuilder: (context, index) => _buildPage(_pages[index], index),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: _pages.length,
                effect: WormEffect(
                  activeDotColor: isDark ? Colors.amber : Colors.white,
                  dotColor: isDark ? Colors.white24 : Colors.white54,
                  dotHeight: 14,
                  dotWidth: 14,
                  spacing: 12,
                  paintStyle: PaintingStyle.fill,
                  type: WormType.thin,
                ),
              ),
            ),
          ),
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
            child: ScaleTransition(
              scale: _buttonScaleAnim,
              child: ElevatedButton(
                onPressed: () async {
                  await _buttonAnimController.reverse();
                  await Future.delayed(const Duration(milliseconds: 40));
                  await _buttonAnimController.forward();
                  _handleNavigation(skip: isLastPage);
                },
                child: Text(isLastPage ? 'Get Started' : 'Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 8,
                  shadowColor: theme.primaryColor.withOpacity(0.3),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          if (!isLastPage)
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
                onPressed: () => _handleNavigation(skip: true),
                child: Text(
                'Skip',
                  style: TextStyle(color: isDark ? Colors.amber : Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.black.withOpacity(0.08),
                ),
            ),
          ),
        ],
      ),
    );
  }
}


