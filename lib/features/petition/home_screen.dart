import 'package:flutter/material.dart';

import '../../shared/layouts/page_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageLayout(
      child: Center(child: Text('Welcome to the Home Screen!')),
    );
  }
}
