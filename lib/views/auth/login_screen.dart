import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenue sur BudgetFlow',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
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
              child: const Text('Se connecter'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.register);
              },
              child: const Text('Créer un compte'),
            ),
          ],
        ),
      ),
    );
  }
}
