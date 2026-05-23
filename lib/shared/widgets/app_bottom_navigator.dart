import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'glass_card.dart';

class AppBottomNavItem {
  final String label;
  final IconData icon;
  final String route;

  const AppBottomNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class AppBottomNavigator extends StatelessWidget {
  static const double _iconSlotSize = 50;
  static const double _navBarHeight = 64;

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNavigator({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  Widget _buildNavIcon(IconData icon) {
    return SizedBox.square(
      dimension: _iconSlotSize,
      child: Center(
        child: Icon(icon, size: 32, color: Colors.white.withValues(alpha: 0.9)),
      ),
    );
  }

  Widget _buildSelectedNavIcon(IconData icon) {
    return SizedBox.square(
      dimension: _iconSlotSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.purple200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(child: Icon(icon, size: 32, color: Colors.white)),
      ),
    );
  }

  Widget _buildDestination(int index, AppBottomNavItem item) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Center(
          child: isSelected
              ? _buildSelectedNavIcon(item.icon)
              : _buildNavIcon(item.icon),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      child: GlassCard(
        width: double.infinity,
        height: 85,
        child: Center(
          child: SizedBox(
            height: _navBarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < items.length; index++)
                  _buildDestination(index, items[index]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
