import 'package:flutter/material.dart';

class PetitionHistoryScreen extends StatelessWidget {
  const PetitionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Histórico de Petições',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
