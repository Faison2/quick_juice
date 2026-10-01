import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassNavItem {
  final IconData icon;
  final String label;

  const GlassNavItem({required this.icon, required this.label});
}

class GlassBottomNav extends StatelessWidget {
  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (i) {
            final item = items[i];
            final selected = i == currentIndex;
            return InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.brandGreen : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: selected ? Colors.white : AppColors.inkMuted,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
