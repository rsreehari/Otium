import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class RoleCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void didUpdateWidget(RoleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward(from: 0);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        if (!widget.isSelected) _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        if (!widget.isSelected) _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSelected ? 1.0 : _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: widget.isSelected ? AppColors.secondary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.primary
                      : Colors.grey.shade200,
                  width: widget.isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: widget.isSelected ? 16 : 8,
                    offset: Offset(0, widget.isSelected ? 6 : 3),
                    spreadRadius: widget.isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.grey.shade100,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? AppColors.primary
                          : Colors.grey.shade500,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: widget.isSelected
                            ? AppColors.primary
                            : AppColors.textBody,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: widget.isSelected ? 1.0 : 0.0,
                    child: Transform.scale(
                      scale: _checkAnimation.value,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
