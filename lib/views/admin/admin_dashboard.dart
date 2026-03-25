import 'package:flutter/material.dart';
import 'package:budgetflow/l10n/app_localizations.dart';

import '../../routes/app_routes.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navAdmin)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adminDashboardTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            _AdminTile(
              title: l10n.adminGlobalCategoriesTitle,
              subtitle: l10n.adminGlobalCategoriesSubtitle,
              icon: Icons.category_outlined,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.adminCategories),
            ),
            const SizedBox(height: 12),
            _AdminTile(
              title: l10n.adminGlobalStatsTitle,
              subtitle: l10n.adminGlobalStatsSubtitle,
              icon: Icons.insights_outlined,
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminStats),
            ),
            const SizedBox(height: 12),
            _AdminTile(
              title: l10n.adminManageUsersTitle,
              subtitle: l10n.adminManageUsersSubtitle,
              icon: Icons.people_outline,
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
            ),
            const SizedBox(height: 12),
            _AdminTile(
              title: l10n.adminFeedbacksTitle,
              subtitle: l10n.adminFeedbacksSubtitle,
              icon: Icons.chat_bubble_outline,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.adminFeedbacks),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
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
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
