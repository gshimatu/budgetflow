import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';
import 'transaction_form.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  _DateFilter _filter = _DateFilter.all;
  DateTime? _customDay;
  String _currencyForForm = 'CDF';
  String _baseCurrencyForForm = 'CDF';
  double _rateForForm = 1.0;

  Future<void> _openAddTransaction(BuildContext context, String uid) async {
    await showTransactionForm(
      context,
      uid: uid,
      currency: _currencyForForm,
      baseCurrency: _baseCurrencyForForm,
      rate: _rateForForm,
    );
  }

  Future<void> _openEditTransaction(
    BuildContext context,
    String uid,
    TransactionModel existing,
  ) async {
    await showTransactionForm(
      context,
      uid: uid,
      existing: existing,
      currency: _currencyForForm,
      baseCurrency: _baseCurrencyForForm,
      rate: _rateForForm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transactions')),
        body: const Center(
          child: Text('Connectez-vous pour voir vos transactions.'),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            onPressed: () async {
              final selected = await _showFilterSheet(context);
              if (!mounted || selected == null) return;
              setState(() => _filter = selected);
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: FirestoreService().watchUserProfile(user.uid),
        builder: (context, profileSnapshot) {
          final profile = profileSnapshot.data ?? {};
          final prefs =
              (profile['preferences'] as Map?)?.cast<String, dynamic>() ?? {};
          final currency = prefs['currency'] as String? ?? 'CDF';
          final baseCurrency =
              (prefs['baseCurrency'] as String?) ?? currency;
          final rate = (prefs['rate'] as num?)?.toDouble() ?? 1.0;
          _currencyForForm = currency;
          _baseCurrencyForForm = baseCurrency;
          _rateForForm = rate;
          return StreamBuilder<List<TransactionModel>>(
            stream: FirestoreService().watchTransactions(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final transactions = snapshot.data ?? [];
              if (transactions.isEmpty) {
                return const Center(
                  child: Text('Aucune transaction enregistree.'),
                );
              }

              final filteredTransactions =
                  _applyFilter(transactions, _filter, _customDay);
              if (filteredTransactions.isEmpty) {
                return Center(
                  child: Text(_emptyMessageForFilter(_filter)),
                );
              }

              final summary = _buildSummary(filteredTransactions);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  _SummaryCard(summary: summary, currency: currency, rate: rate),
                  const SizedBox(height: 12),
                  _FilterChips(
                    selected: _filter,
                    onSelected: (value) async {
                      if (value == _DateFilter.day) {
                        final picked = await _pickDay(context);
                        if (picked == null) return;
                        setState(() {
                          _customDay = picked;
                          _filter = value;
                        });
                        return;
                      }
                      setState(() => _filter = value);
                    },
                    selectedDay: _customDay,
                  ),
                  const SizedBox(height: 16),
                  ...filteredTransactions.map(
                    (tx) => _TransactionTile(
                      tx: tx,
                      currency: currency,
                      rate: rate,
                      onEdit: () => _openEditTransaction(context, user.uid, tx),
                      onDelete: () => _confirmDelete(context, user.uid, tx),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransaction(context, user.uid),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String uid,
    TransactionModel tx,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la transaction'),
          content: const Text(
            'Voulez-vous vraiment supprimer cette transaction ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    await FirestoreService().deleteTransaction(uid, tx.id);
  }

  Future<_DateFilter?> _showFilterSheet(BuildContext context) {
    return showModalBottomSheet<_DateFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrer les transactions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              ..._DateFilter.values.map(
                (filter) => ListTile(
                  title: Text(_labelForFilter(filter)),
                  trailing: _filter == filter
                      ? Icon(Icons.check, color: scheme.primary)
                      : null,
                  onTap: () => Navigator.pop(context, filter),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<DateTime?> _pickDay(BuildContext context) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: _customDay ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
  }
}

enum _DateFilter { all, today, day, week, month, year }

String _labelForFilter(_DateFilter filter) {
  switch (filter) {
    case _DateFilter.today:
      return 'Aujourd\'hui';
    case _DateFilter.day:
      return 'Choisir un jour';
    case _DateFilter.week:
      return 'Cette semaine';
    case _DateFilter.month:
      return 'Ce mois';
    case _DateFilter.year:
      return 'Cette annee';
    case _DateFilter.all:
    default:
      return 'Toutes';
  }
}

String _emptyMessageForFilter(_DateFilter filter) {
  switch (filter) {
    case _DateFilter.today:
      return 'Aucune transaction aujourd\'hui.';
    case _DateFilter.day:
      return 'Aucune transaction pour ce jour.';
    case _DateFilter.week:
      return 'Aucune transaction cette semaine.';
    case _DateFilter.month:
      return 'Aucune transaction ce mois.';
    case _DateFilter.year:
      return 'Aucune transaction cette annee.';
    case _DateFilter.all:
    default:
      return 'Aucune transaction enregistree.';
  }
}

List<TransactionModel> _applyFilter(
  List<TransactionModel> items,
  _DateFilter filter,
  DateTime? customDay,
) {
  final now = DateTime.now();
  DateTime start;
  DateTime end;

  switch (filter) {
    case _DateFilter.today:
      start = DateTime(now.year, now.month, now.day);
      end = start.add(const Duration(days: 1));
      break;
    case _DateFilter.day:
      final base = customDay ?? now;
      start = DateTime(base.year, base.month, base.day);
      end = start.add(const Duration(days: 1));
      break;
    case _DateFilter.week:
      start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      end = start.add(const Duration(days: 7));
      break;
    case _DateFilter.month:
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 1);
      break;
    case _DateFilter.year:
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year + 1, 1, 1);
      break;
    case _DateFilter.all:
    default:
      return items;
  }

  return items.where((tx) {
    final date = tx.date;
    return (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
        date.isBefore(end);
  }).toList();
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onSelected,
    required this.selectedDay,
  });

  final _DateFilter selected;
  final ValueChanged<_DateFilter> onSelected;
  final DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _DateFilter.values.map((filter) {
        final label = filter == _DateFilter.day && selectedDay != null
            ? 'Jour: ${DateFormat('dd/MM').format(selectedDay!)}'
            : _labelForFilter(filter);
        return ChoiceChip(
          label: Text(label),
          selected: selected == filter,
          onSelected: (_) => onSelected(filter),
        );
      }).toList(),
    );
  }
}

class _SummaryData {
  const _SummaryData({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  final double totalIncome;
  final double totalExpense;
  final double balance;
}

_SummaryData _buildSummary(List<TransactionModel> items) {
  double income = 0;
  double expense = 0;
  for (final item in items) {
    if (_isIncome(item.type)) {
      income += item.amount;
    } else {
      expense += item.amount;
    }
  }
  return _SummaryData(
    totalIncome: income,
    totalExpense: expense,
    balance: income - expense,
  );
}

bool _isIncome(String type) {
  final value = type.toLowerCase();
  return value.contains('revenu') || value == 'income';
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.currency, required this.rate});

  final _SummaryData summary;
  final String currency;
  final double rate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF33CC33), Color(0xFF0BC1DE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solde actuel',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            _formatMoney(summary.balance, currency, rate),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Revenus',
                  value: _formatMoney(summary.totalIncome, currency, rate),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Depenses',
                  value: _formatMoney(summary.totalExpense, currency, rate),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.tx,
    required this.currency,
    required this.rate,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionModel tx;
  final String currency;
  final double rate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isIncome = _isIncome(tx.type);
    final amountColor =
        isIncome ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
    final label = tx.categoryName?.isNotEmpty == true
        ? tx.categoryName!
        : tx.categoryId;
    final dateLabel = DateFormat('dd MMM yyyy').format(tx.date);
    final timeLabel = DateFormat('HH:mm').format(tx.date);

    return InkWell(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
                color: amountColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: amountColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateLabel - $timeLabel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  if (tx.note != null && tx.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      tx.note!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'} ${_formatMoney(tx.amount, currency, rate)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: const Color(0xFFEF4444),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMoney(double value, String currency, double rate) {
  final formatter = NumberFormat.decimalPattern();
  return '${formatter.format((value * rate).round())} $currency';
}
