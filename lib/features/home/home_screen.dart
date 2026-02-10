import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/intervention_service.dart';
import '../../widgets/full_screen_container.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_indicator.dart';

/// HomeScreen: Entry point for focus sprints.
///
/// Also handles:
/// - Overlay permission check/request for Android intervention
/// - Calm, breathing-aligned aesthetic
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final InterventionService _interventionService = InterventionService();
  bool _hasOverlayPermission = false;
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
    _checkOverlayPermission();
  }

  Future<void> _checkOverlayPermission() async {
    if (_interventionService.isAndroid) {
      final hasPermission = await _interventionService.hasOverlayPermission();
      if (mounted) {
        setState(() {
          _hasOverlayPermission = hasPermission;
          _permissionChecked = true;
        });
      }
    } else {
      setState(() => _permissionChecked = true);
    }
  }

  Future<void> _requestPermission() async {
    await _interventionService.requestOverlayPermission();
    // Re-check after returning from settings
    Future.delayed(const Duration(milliseconds: 500), _checkOverlayPermission);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenContainer(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const StateIndicator(status: 'CALM', color: AppColors.calm),
            const Spacer(),
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Decorative circles
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.accent.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.psychology_outlined,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  const Text(
                    'Ready to focus?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Start a 90-minute sprint to reclaim your biological capacity to think.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  // Animated button with glow
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3 * value),
                              blurRadius: 20 * value,
                              spreadRadius: 2 * value,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: PrimaryButton(
                          label: 'Start Focus Sprint',
                          onPressed: () => context.go('/sprint'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Overlay permission status (Android only)
                  if (_interventionService.isAndroid &&
                      _permissionChecked &&
                      !_hasOverlayPermission)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: 1.0,
                      child: GestureDetector(
                        onTap: _requestPermission,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 16,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Enable overlay for intervention',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.orange.shade700,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Last recovery info with fade
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: 1.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Last recovery: 2h ago',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'All data stays on your device',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
