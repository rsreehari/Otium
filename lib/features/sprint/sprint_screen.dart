import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/sprint_provider.dart';
import '../../state/fatigue_provider.dart';
import '../../models/session.dart';
import '../../widgets/full_screen_container.dart';
import 'sprint_timer.dart';

/// SprintScreen: Minimal, breathing-aligned focus timer.
///
/// Design Philosophy:
/// - ONLY the timer should be visible
/// - Zero cognitive load from UI chrome
/// - Interaction tracking is invisible (pattern sensing)
/// - Breathing rhythm through subtle pulse animation
class SprintScreen extends StatefulWidget {
  const SprintScreen({super.key});

  @override
  State<SprintScreen> createState() => _SprintScreenState();
}

class _SprintScreenState extends State<SprintScreen>
    with WidgetsBindingObserver {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SprintProvider>().startSprint();
        context.read<FatigueProvider>().reset();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Pattern sensing: app switch is recorded invisibly
      context.read<FatigueProvider>().reportAppSwitch();
    }
  }

  void _navigateIfNeeded(String route) {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(route);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sprint = context.watch<SprintProvider>();
    final fatigue = context.watch<FatigueProvider>();

    // Navigation guards
    if (fatigue.isFatigued) {
      _navigateIfNeeded('/intervention');
    } else if (sprint.sessionState == SessionState.recovery) {
      _navigateIfNeeded('/recovery');
    }

    return GestureDetector(
      // Invisible friction tracking - taps are sensed, not counted visually
      onTap: () => context.read<FatigueProvider>().incrementFriction(),
      behavior: HitTestBehavior.opaque,
      child: FullScreenContainer(
        backgroundColor: Colors.blueGrey.shade50,
        child: Center(
          // Pure visual focus: only the timer, nothing else
          child: SprintTimer(timeLeft: sprint.timeLeft),
        ),
      ),
    );
  }
}
