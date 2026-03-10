import 'package:flutter/material.dart';

class GlobalStatsScreen extends StatelessWidget {
  const GlobalStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques globales')),
      body: const Center(
        child: Text('Statistiques globales anonymisées'),
      ),
    );
  }
}
