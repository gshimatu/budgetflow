import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/firestore_service.dart';

class GlobalStatsScreen extends StatelessWidget {
  const GlobalStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques globales')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: FirestoreService().getGlobalStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erreur de chargement des statistiques.\n'
                  'Verifie le role admin et les regles publiees.\n'
                  'Details: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final data = snapshot.data ?? {};
          final users = data['users'] as int? ?? 0;
          final transactions = data['transactions'] as int? ?? 0;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (users == 0 && transactions == 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Aucune donnee detectee. Verifie le role admin, '
                    'les regles publiees et le projet Firebase utilise.',
                  ),
                ),
              _StatCard(
                title: 'Utilisateurs',
                value: users.toString(),
                icon: Icons.people_outline,
                color: const Color(0xFF0BC1DE),
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Transactions',
                value: transactions.toString(),
                icon: Icons.swap_horiz,
                color: const Color(0xFF6366F1),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatMoney(double value) {
  final formatter = NumberFormat.decimalPattern();
  return '${formatter.format(value.round())} CDF';
}
