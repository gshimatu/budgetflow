import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_model.dart';
import '../../services/api_service.dart';
import '../../services/firestore_service.dart';
import 'transaction_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onViewAllTransactions});

  final VoidCallback? onViewAllTransactions;

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF33CC33);
    const brandCyan = Color(0xFF0BC1DE);
    const brandOrange = Color(0xFFFC7520);

    final user = FirebaseAuth.instance.currentUser;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [brandCyan, Color(0xFFB9F3FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [brandGreen, Color(0xFFBFF5C8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            if (user == null)
              const Center(child: Text('Connectez-vous pour voir vos données.'))
            else
              StreamBuilder<Map<String, dynamic>>(
                stream: FirestoreService().watchUserProfile(user.uid),
                builder: (context, profileSnapshot) {
                  final profile = profileSnapshot.data ?? {};
                  final prefs =
                      (profile['preferences'] as Map?)?.cast<String, dynamic>() ??
                          {};
                  final currency = prefs['currency'] as String? ?? 'CDF';
                  final baseCurrency =
                      (prefs['baseCurrency'] as String?) ?? currency;
                  final rate = (prefs['rate'] as num?)?.toDouble() ?? 1.0;
                  return StreamBuilder<List<TransactionModel>>(
                    stream: FirestoreService().watchTransactions(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final transactions = snapshot.data ?? [];
                      final summary = _buildSummary(transactions);
                      final recent = transactions.take(3).toList();

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeaderSection(
                              brandOrange: brandOrange,
                              brandGreen: brandGreen,
                            ),
                            const SizedBox(height: 20),
                            _BalanceCard(
                              brandGreen: brandGreen,
                              brandCyan: brandCyan,
                              balance: summary.balance,
                              income: summary.totalIncome,
                              expense: summary.totalExpense,
                              currency: currency,
                              rate: rate,
                            ),
                            const SizedBox(height: 20),
                            _QuickActions(
                              brandOrange: brandOrange,
                              onAddExpense: () async {
                                if (user == null) return;
                                await showTransactionForm(
                                  context,
                                  uid: user.uid,
                                  initialType: 'expense',
                                  currency: currency,
                                  baseCurrency: baseCurrency,
                                  rate: rate,
                                );
                              },
                              onAddIncome: () async {
                                if (user == null) return;
                                await showTransactionForm(
                                  context,
                                  uid: user.uid,
                                  initialType: 'income',
                                  currency: currency,
                                  baseCurrency: baseCurrency,
                                  rate: rate,
                                );
                              },
                              onConvert: () => _openConverter(context),
                            ),
                            const SizedBox(height: 20),
                            _BudgetOverview(
                              brandGreen: brandGreen,
                              uid: user.uid,
                              totalExpense: summary.totalExpense,
                              currency: currency,
                              rate: rate,
                            ),
                            const SizedBox(height: 20),
                            _InsightsRow(
                              brandCyan: brandCyan,
                              brandOrange: brandOrange,
                              income: summary.totalIncome,
                              expense: summary.totalExpense,
                              currency: currency,
                              rate: rate,
                            ),
                            const SizedBox(height: 20),
                            _RecentTransactions(
                              transactions: recent,
                              onViewAll: onViewAllTransactions,
                              currency: currency,
                              rate: rate,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openConverter(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  String from = 'USD';
  String to = 'CDF';
  String? result;
  bool loading = false;
  String? error;

  final currencies = ['USD', 'EUR', 'CDF', 'GBP', 'ZAR', 'NGN'];

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final scheme = Theme.of(context).colorScheme;
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Convertisseur',
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Montant',
                        prefixIcon: const Icon(Icons.payments_outlined),
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
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
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: from,
                            items: currencies
                                .map(
                                  (code) => DropdownMenuItem(
                                    value: code,
                                    child: Text(code),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => from = value);
                            },
                            decoration: InputDecoration(
                              labelText: 'De',
                              filled: true,
                              fillColor: scheme.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: to,
                            items: currencies
                                .map(
                                  (code) => DropdownMenuItem(
                                    value: code,
                                    child: Text(code),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => to = value);
                            },
                            decoration: InputDecoration(
                              labelText: 'Vers',
                              filled: true,
                              fillColor: scheme.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (error != null)
                      Text(
                        error!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.redAccent),
                      ),
                    if (result != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        result!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: loading
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                setState(() {
                                  loading = true;
                                  error = null;
                                });
                                try {
                                  final amount = double.parse(
                                    amountController.text
                                        .trim()
                                        .replaceAll(',', '.'),
                                  );
                                  final rate = await ApiService().getRate(
                                    from: from,
                                    to: to,
                                  );
                                  final converted = amount * rate;
                                  setState(() {
                                    result =
                                        '${converted.toStringAsFixed(2)} $to';
                                  });
                                } catch (e) {
                                  setState(() {
                                    error = e.toString().replaceFirst(
                                          'Exception: ',
                                          '',
                                        );
                                  });
                                } finally {
                                  setState(() => loading = false);
                                }
                              },
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Convertir'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
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

String _formatMoney(double value, String currency, double rate) {
  final formatter = NumberFormat.decimalPattern();
  return '${formatter.format((value * rate).round())} $currency';
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.brandOrange,
    required this.brandGreen,
  });

  final Color brandOrange;
  final Color brandGreen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final dateLabel = DateFormat('dd MMM yyyy').format(now);
    final timeLabel = DateFormat('HH:mm').format(now);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo-budgetflow.png',
            width: 48,
            height: 48,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour,',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Row(
                children: [
                  Text(
                    'BudgetFlow',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$dateLabel - $timeLabel',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.brandGreen,
    required this.brandCyan,
    required this.balance,
    required this.income,
    required this.expense,
    required this.currency,
    required this.rate,
  });

  final Color brandGreen;
  final Color brandCyan;
  final double balance;
  final double income;
  final double expense;
  final String currency;
  final double rate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [brandGreen, brandCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: brandGreen.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
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
            _formatMoney(balance, currency, rate),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _BalanceChip(
                label: 'Revenus ${_formatMoney(income, currency, rate)}',
                icon: Icons.trending_up,
              ),
              _BalanceChip(
                label: 'Dépenses ${_formatMoney(expense, currency, rate)}',
                icon: Icons.trending_down,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.brandOrange,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onConvert,
  });

  final Color brandOrange;
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onConvert;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                label: 'Ajouter dépense',
                icon: Icons.remove_circle_outline,
                color: brandOrange,
                onTap: onAddExpense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                label: 'Ajouter revenu',
                icon: Icons.add_circle_outline,
                color: const Color(0xFF22C55E),
                onTap: onAddIncome,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                label: 'Convertir',
                icon: Icons.currency_exchange,
                color: const Color(0xFF0BC1DE),
                onTap: onConvert,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetOverview extends StatefulWidget {
  const _BudgetOverview({
    required this.brandGreen,
    required this.uid,
    required this.totalExpense,
    required this.currency,
    required this.rate,
  });

  final Color brandGreen;
  final String uid;
  final double totalExpense;
  final String currency;
  final double rate;

  @override
  State<_BudgetOverview> createState() => _BudgetOverviewState();
}

class _BudgetOverviewState extends State<_BudgetOverview> {
  double? _localGoal;

  Future<void> _editMonthlyGoal({
    required double currentGoal,
  }) async {
    final controller = TextEditingController(
      text: currentGoal.toStringAsFixed(0),
    );
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
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
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Definir l\'objectif mensuel',
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: controller,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Montant (${widget.currency})',
                          prefixIcon: const Icon(Icons.flag_outlined),
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest,
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
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  setState(() => saving = true);
                                  try {
                                    final parsed = double.parse(
                                      controller.text
                                          .trim()
                                          .replaceAll(',', '.'),
                                    );
                                    await FirestoreService()
                                        .updateUserPreferences(
                                      widget.uid,
                                      monthlyGoal: parsed,
                                    );
                                    if (mounted) {
                                      setState(() => _localGoal = parsed);
                                    }
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Objectif mis a jour.'),
                                      ),
                                    );
                                  } catch (_) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Impossible de mettre a jour.',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => saving = false);
                                    }
                                  }
                                },
                          child: saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Enregistrer'),
                        ),
                      ),
                    ],
                  ),
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
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirestoreService().watchUserProfile(widget.uid),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final prefs =
            (data['preferences'] as Map?)?.cast<String, dynamic>() ?? {};
        final goal =
            _localGoal ?? (prefs['monthlyGoal'] as num?)?.toDouble() ?? 0;
        final progress =
            goal <= 0
                ? 0.0
                : (widget.totalExpense / goal).clamp(0.0, 1.0) as double;
        final remaining = goal <= 0
            ? 0.0
            : (goal - widget.totalExpense).clamp(0, goal).toDouble();
        final percent = (progress * 100).round();

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Objectif mensuel',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        goal <= 0 ? 'A definir' : '$percent%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: widget.brandGreen,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      IconButton(
                        onPressed: () => _editMonthlyGoal(
                          currentGoal: goal <= 0 ? 0 : goal,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        color: widget.brandGreen,
                        tooltip: 'Modifier',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE6EEF6),
                  color: widget.brandGreen,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                goal <= 0
                    ? 'Definis ton objectif pour ce mois'
                    : 'Budget restant : ${_formatMoney(remaining, widget.currency, widget.rate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InsightsRow extends StatelessWidget {
  const _InsightsRow({
    required this.brandCyan,
    required this.brandOrange,
    required this.income,
    required this.expense,
    required this.currency,
    required this.rate,
  });

  final Color brandCyan;
  final Color brandOrange;
  final double income;
  final double expense;
  final String currency;
  final double rate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InsightCard(
            title: 'Dépenses du mois',
            value: _formatMoney(expense, currency, rate),
            color: brandOrange,
            icon: Icons.shopping_bag_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InsightCard(
            title: 'Revenus du mois',
            value: _formatMoney(income, currency, rate),
            color: brandCyan,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({
    required this.transactions,
    required this.currency,
    required this.rate,
    this.onViewAll,
  });

  final List<TransactionModel> transactions;
  final String currency;
  final double rate;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions récentes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Aucune transaction pour le moment.'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions récentes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...transactions.map(
          (tx) => _TransactionTile(
            tx: tx,
            currency: currency,
            rate: rate,
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.tx,
    required this.currency,
    required this.rate,
  });

  final TransactionModel tx;
  final String currency;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isIncome = _isIncome(tx.type);
    final amountColor =
        isIncome ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
    final label = tx.categoryName?.isNotEmpty == true
        ? tx.categoryName!
        : tx.categoryId;
    final dateLabel = DateFormat('dd MMM').format(tx.date);
    return Container(
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.15),
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
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                ),
                if (tx.originalCurrency != null &&
                    tx.originalCurrency!.isNotEmpty &&
                    tx.originalCurrency != currency) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Devise: ${tx.originalCurrency} -> $currency',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${_formatMoney(tx.amount, currency, rate)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
          ),
        ],
      ),
    );
  }
}
