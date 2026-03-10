import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  Future<void> _openAddTransaction(BuildContext context, String uid) async {
    await _openTransactionForm(context, uid);
  }

  Future<void> _openEditTransaction(
    BuildContext context,
    String uid,
    TransactionModel existing,
  ) async {
    await _openTransactionForm(context, uid, existing: existing);
  }

  Future<void> _openTransactionForm(
    BuildContext context,
    String uid, {
    TransactionModel? existing,
  }) async {
    final formKey = GlobalKey<FormState>();
    final amountController =
        TextEditingController(text: existing?.amount.toString());
    final noteController = TextEditingController(text: existing?.note ?? '');
    DateTime selectedDate = existing?.date ?? DateTime.now();
    String type = existing?.type ?? 'expense';
    String? selectedCategory = existing?.categoryName;
    String? customCategory;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: StreamBuilder<List<CategoryModel>>(
                  stream: FirestoreService().watchGlobalCategories(),
                  builder: (context, globalSnapshot) {
                    return StreamBuilder<List<CategoryModel>>(
                      stream: FirestoreService().watchUserCategories(uid),
                      builder: (context, userSnapshot) {
                        final globalCategories = globalSnapshot.data ?? [];
                        final userCategories = userSnapshot.data ?? [];
                        final names = <String>{};
                        for (final cat in [...globalCategories, ...userCategories]) {
                          if (cat.name.trim().isNotEmpty) {
                            names.add(cat.name.trim());
                          }
                        }
                        final categoryItems = names.toList()..sort();
                        if (selectedCategory == null) {
                          selectedCategory = categoryItems.isNotEmpty
                              ? categoryItems.first
                              : 'Autre';
                        }
                        final isCustomCategory = selectedCategory != null &&
                            !categoryItems.contains(selectedCategory) &&
                            selectedCategory != 'Autre';
                        if (isCustomCategory && customCategory == null) {
                          customCategory = selectedCategory;
                          selectedCategory = 'Autre';
                        }
                        return Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Nouvelle transaction',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Montant',
                                  prefixIcon:
                                      const Icon(Icons.payments_outlined),
                                  suffixText: 'CDF',
                                  filled: true,
                                  fillColor: const Color(0xFFF2F6FA),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Veuillez saisir un montant';
                                  }
                                  final parsed = double.tryParse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (parsed == null || parsed <= 0) {
                                    return 'Montant invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: type,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'expense',
                                    child: Text('Dépense'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'income',
                                    child: Text('Revenu'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => type = value);
                                },
                                decoration: InputDecoration(
                                  labelText: 'Type',
                                  filled: true,
                                  fillColor: const Color(0xFFF2F6FA),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: selectedCategory,
                                items: [
                                  ...categoryItems.map(
                                    (name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(name),
                                    ),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'Autre',
                                    child: Text('Autre'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => selectedCategory = value);
                                },
                                decoration: InputDecoration(
                                  labelText: 'Catégorie',
                                  prefixIcon:
                                      const Icon(Icons.category_outlined),
                                  filled: true,
                                  fillColor: const Color(0xFFF2F6FA),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Veuillez choisir une catégorie';
                                  }
                                  return null;
                                },
                              ),
                              if (selectedCategory == 'Autre') ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Nom de la catégorie',
                                    prefixIcon:
                                        const Icon(Icons.edit_outlined),
                                    filled: true,
                                    fillColor: const Color(0xFFF2F6FA),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      customCategory = value,
                                  validator: (value) {
                                    if (selectedCategory == 'Autre' &&
                                        (value == null ||
                                            value.trim().isEmpty)) {
                                      return 'Veuillez saisir une catégorie';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: noteController,
                                decoration: InputDecoration(
                                  labelText: 'Note (optionnel)',
                                  prefixIcon: const Icon(Icons.note_outlined),
                                  filled: true,
                                  fillColor: const Color(0xFFF2F6FA),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2100),
                                        initialDate: selectedDate,
                                      );
                                      if (picked != null) {
                                        setState(() => selectedDate = picked);
                                      }
                                    },
                                    child: const Text('Choisir'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () async {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    final amount = double.parse(
                                      amountController.text
                                          .trim()
                                          .replaceAll(',', '.'),
                                    );
                                    final chosen = selectedCategory == 'Autre'
                                        ? (customCategory ?? '')
                                        : (selectedCategory ?? '');
                                    final categoryName = chosen.trim();
                                    final transaction = TransactionModel(
                                      id: existing?.id ?? '',
                                      amount: amount,
                                      type: type,
                                      categoryId:
                                          categoryName.toLowerCase().trim(),
                                      categoryName: categoryName,
                                      date: selectedDate,
                                      note: noteController.text.trim(),
                                    );
                                    if (existing == null) {
                                      await FirestoreService()
                                          .addTransaction(uid, transaction);
                                    } else {
                                      await FirestoreService().updateTransaction(
                                        uid,
                                        existing.id,
                                        transaction,
                                      );
                                    }
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    existing == null ? 'Ajouter' : 'Mettre à jour',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: FirestoreService().watchTransactions(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return const Center(
              child: Text('Aucune transaction enregistrée.'),
            );
          }

          final summary = _buildSummary(transactions);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _SummaryCard(summary: summary),
              const SizedBox(height: 16),
              ...transactions.map(
                (tx) => _TransactionTile(
                  tx: tx,
                  onEdit: () => _openEditTransaction(context, user.uid, tx),
                  onDelete: () => _confirmDelete(context, user.uid, tx),
                ),
              ),
            ],
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
  const _SummaryCard({required this.summary});

  final _SummaryData summary;

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
            _formatMoney(summary.balance),
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
                  value: _formatMoney(summary.totalIncome),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Dépenses',
                  value: _formatMoney(summary.totalExpense),
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
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionModel tx;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = _isIncome(tx.type);
    final amountColor =
        isIncome ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
    final label = tx.categoryName?.isNotEmpty == true
        ? tx.categoryName!
        : tx.categoryId;
    final dateLabel = DateFormat('dd MMM yyyy').format(tx.date);

    return InkWell(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    dateLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  if (tx.note != null && tx.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      tx.note!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black45,
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
                  '${isIncome ? '+' : '-'} ${_formatMoney(tx.amount)}',
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

String _formatMoney(double value) {
  final formatter = NumberFormat.decimalPattern();
  return '${formatter.format(value.round())} CDF';
}
