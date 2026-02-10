import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../widgets/full_screen_container.dart';
import '../../widgets/primary_button.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen>
    with SingleTickerProviderStateMixin {
  double _energyLevel = 5;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getEnergyColor() {
    if (_energyLevel <= 3) return AppColors.fatigued;
    if (_energyLevel <= 6) return AppColors.strained;
    return AppColors.calm;
  }

  String _getEnergyEmoji() {
    if (_energyLevel <= 2) return '😔';
    if (_energyLevel <= 4) return '😐';
    if (_energyLevel <= 6) return '🙂';
    if (_energyLevel <= 8) return '😊';
    return '🌟';
  }

  String _getEnergyLabel() {
    if (_energyLevel <= 2) return 'Very Low';
    if (_energyLevel <= 4) return 'Low';
    if (_energyLevel <= 6) return 'Moderate';
    if (_energyLevel <= 8) return 'Good';
    return 'Excellent';
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenContainer(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'How do you feel now?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rate your post-recovery energy level',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const Spacer(),
              // Energy level display with animations
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 400),
                key: ValueKey(_energyLevel.round()),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Column(
                      children: [
                        // Emoji indicator
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            _getEnergyEmoji(),
                            key: ValueKey(_getEnergyEmoji()),
                            style: const TextStyle(fontSize: 60),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Numeric display with animated color
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: _getEnergyColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _getEnergyColor().withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getEnergyColor().withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.w300,
                                  color: _getEnergyColor(),
                                ),
                                child: Text(_energyLevel.round().toString()),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  _getEnergyLabel(),
                                  key: ValueKey(_getEnergyLabel()),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _getEnergyColor(),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Custom slider with animated track
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: _getEnergyColor(),
                        inactiveTrackColor: _getEnergyColor().withOpacity(0.2),
                        thumbColor: _getEnergyColor(),
                        overlayColor: _getEnergyColor().withOpacity(0.2),
                        trackHeight: 8,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 14,
                          elevation: 4,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 24,
                        ),
                      ),
                      child: Slider(
                        value: _energyLevel,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (val) => setState(() => _energyLevel = val),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.fatigued,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Drained',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Energized',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.calm,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Completion button with scale animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.9, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: PrimaryButton(
                      label: 'Complete Session',
                      onPressed: () => context.go('/dashboard'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
