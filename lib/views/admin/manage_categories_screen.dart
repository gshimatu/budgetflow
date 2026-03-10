import 'package:flutter/material.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catégories globales')),
      body: const Center(
        child: Text('Gestion des catégories globales'),
      ),
    );
  }
}
