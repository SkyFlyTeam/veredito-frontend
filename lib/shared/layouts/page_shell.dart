import 'package:flutter/material.dart';

import '../widgets/app_bottom_navigator.dart';

class PageShell extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final AppBottomNavigator? bottomNavigator;

  const PageShell({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigator,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigator,
    );
  }
}
