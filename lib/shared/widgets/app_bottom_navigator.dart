import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import 'glass_card.dart';

class AppBottomNavItem {
  final String label;
  final String svgPath;
  final String route;

  const AppBottomNavItem({
    required this.label,
    required this.svgPath,
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

  Widget _buildIcon(AppBottomNavItem item, {required bool selected}) {
    final color = selected ? Colors.white : Colors.white.withValues(alpha: 0.6);

    return SizedBox.square(
      dimension: _iconSlotSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.purple200 : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: SvgPicture.asset(
            item.svgPath,
            width: 34,
            height: 34,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget _buildDestination(int index, AppBottomNavItem item) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Center(
          child: _buildIcon(item, selected: index == currentIndex),
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
