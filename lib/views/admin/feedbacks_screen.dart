import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgetflow/l10n/app_localizations.dart';

import '../../services/firestore_service.dart';

class FeedbacksScreen extends StatelessWidget {
  const FeedbacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.comments)),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().watchFeedbacks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(l10n.adminFeedbackLoadFailed));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(child: Text(l10n.adminNoFeedbacks));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              final item = items[index];
              final type = (item['type'] as String?) ?? 'comment';
              final message = (item['message'] as String?) ?? '';
              final email = (item['email'] as String?) ?? l10n.defaultUserName;
              final createdAt = item['createdAt'];
              String dateLabel = l10n.unknownDate;
              if (createdAt is DateTime) {
                dateLabel = DateFormat('dd MMM yyyy HH:mm').format(createdAt);
              } else if (createdAt != null) {
                try {
                  dateLabel = DateFormat(
                    'dd MMM yyyy HH:mm',
                  ).format(createdAt.toDate());
                } catch (_) {}
              }

              final typeLabel = _labelForType(type);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _colorForType(type).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            typeLabel,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: _colorForType(type),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dateLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemCount: items.length,
          );
        },
      ),
    );
  }

  String _labelForType(String type) {
    switch (type) {
      case 'bug':
        return 'Bug';
      case 'feature':
        return 'Feature';
      case 'comment':
      default:
        return 'Comment';
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'bug':
        return Colors.red;
      case 'feature':
        return Colors.blue;
      case 'comment':
      default:
        return Colors.grey;
    }
  }
}

Color _colorForType(String type) {
  switch (type.toLowerCase()) {
    case 'bug':
      return const Color(0xFFEF4444);
    case 'suggestion':
      return const Color(0xFF0BC1DE);
    default:
      return const Color(0xFF6366F1);
  }
}
