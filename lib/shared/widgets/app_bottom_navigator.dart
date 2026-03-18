import 'package:flutter/material.dart';

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
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNavigator({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(growable: false),
    );
  }
}
