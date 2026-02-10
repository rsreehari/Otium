import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../state/user_provider.dart';
import '../../widgets/full_screen_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Main fade controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Pulsing controller for the logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Slide controller for text
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Staggered animation start
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });

    // Navigate after animations complete
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _checkNavigation();
      }
    });
  }

  void _checkNavigation() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.profile.hasRole) {
      context.go('/');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenContainer(
      backgroundColor: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Organic pulsing logo with smooth animations
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.08),
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.9),
                                  AppColors.primary.withOpacity(0.6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(
                                    0.3 + (_pulseAnimation.value - 0.95) * 2,
                                  ),
                                  blurRadius:
                                      20 + (_pulseAnimation.value - 0.95) * 40,
                                  spreadRadius:
                                      5 + (_pulseAnimation.value - 0.95) * 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      'Otium',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 6,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 0.5 + (_pulseAnimation.value - 0.95) * 3,
                          child: Text(
                            'Restoring cognitive baseline...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
