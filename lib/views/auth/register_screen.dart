import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Créer un compte BudgetFlow',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(labelText: 'Nom complet'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mot de passe'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
              child: const Text('S\'inscrire'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('J\'ai déjà un compte'),
            ),
          ],
        ),
      ),
    );
  }
}
