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
      child: Transform.translate(
        offset: const Offset(0, 10),
        child: Center(
          child: Icon(
            icon,
            size: 32,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedNavIcon(IconData icon) {
    return SizedBox.square(
      dimension: _iconSlotSize,
      child: Transform.translate(
        offset: const Offset(0, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.purple400,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(child: Icon(icon, size: 32, color: Colors.white)),
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
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: items.map((item) {
            return NavigationDestination(
              icon: _buildNavIcon(item.icon),
              selectedIcon: _buildSelectedNavIcon(item.icon),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
