import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistiques')),
        body: const Center(
          child: Text('Connectez-vous pour voir vos statistiques.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(title: const Text('Statistiques')),
      body: StreamBuilder<List<TransactionModel>>(
        stream: FirestoreService().watchTransactions(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return const Center(
              child: Text('Aucune transaction pour le moment.'),
            );
          }

          final summary = _buildSummary(transactions);
          final expensesByCategory = _groupExpensesByCategory(transactions);
          final monthlySeries = _buildMonthlySeries(transactions);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(summary: summary),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Répartition des dépenses'),
                const SizedBox(height: 12),
                _PieChartCard(data: expensesByCategory),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Évolution mensuelle'),
                const SizedBox(height: 12),
                _MonthlyChartCard(data: monthlySeries),
              ],
            ),
          );
        },
      ),
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

Map<String, double> _groupExpensesByCategory(List<TransactionModel> items) {
  final Map<String, double> totals = {};
  for (final item in items) {
    if (_isIncome(item.type)) continue;
    final label = item.categoryName?.isNotEmpty == true
        ? item.categoryName!
        : item.categoryId;
    totals[label] = (totals[label] ?? 0) + item.amount;
  }
  return totals;
}

List<_MonthlyPoint> _buildMonthlySeries(List<TransactionModel> items) {
  final now = DateTime.now();
  final months = List.generate(
    6,
    (index) => DateTime(now.year, now.month - (5 - index)),
  );

  final Map<String, double> income = {};
  final Map<String, double> expense = {};

  for (final item in items) {
    final key = _monthKey(item.date);
    if (_isIncome(item.type)) {
      income[key] = (income[key] ?? 0) + item.amount;
    } else {
      expense[key] = (expense[key] ?? 0) + item.amount;
    }
  }

  return months
      .map(
        (month) => _MonthlyPoint(
          label: DateFormat.MMM().format(month),
          income: income[_monthKey(month)] ?? 0,
          expense: expense[_monthKey(month)] ?? 0,
        ),
      )
      .toList();
}

String _monthKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';

bool _isIncome(String type) {
  final value = type.toLowerCase();
  return value.contains('revenu') || value == 'income';
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final _SummaryData summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Revenus',
            value: _formatMoney(summary.totalIncome),
            color: const Color(0xFF33CC33),
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Dépenses',
            value: _formatMoney(summary.totalExpense),
            color: const Color(0xFFFC7520),
            icon: Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Solde',
            value: _formatMoney(summary.balance),
            color: const Color(0xFF0BC1DE),
            icon: Icons.account_balance_wallet,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
    return Container(
      padding: const EdgeInsets.all(12),
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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _PieChartCard extends StatelessWidget {
  const _PieChartCard({required this.data});

  final Map<String, double> data;

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<double>(0, (a, b) => a + b);
    final colors = const [
      Color(0xFF33CC33),
      Color(0xFF0BC1DE),
      Color(0xFFFC7520),
      Color(0xFF6366F1),
      Color(0xFFF97316),
      Color(0xFF22C55E),
    ];

    final sections = data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = item.value;
      final percent = total == 0 ? 0 : (value / total) * 100;
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: 48,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 32,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...data.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text(_formatMoney(entry.value)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyPoint {
  const _MonthlyPoint({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final double income;
  final double expense;
}

class _MonthlyChartCard extends StatelessWidget {
  const _MonthlyChartCard({required this.data});

  final List<_MonthlyPoint> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        data[index].label,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: data.asMap().entries.map((entry) {
              final index = entry.key;
              final point = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: point.income,
                    color: const Color(0xFF33CC33),
                    width: 8,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  BarChartRodData(
                    toY: point.expense,
                    color: const Color(0xFFFC7520),
                    width: 8,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
                barsSpace: 6,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

String _formatMoney(double value) {
  final formatter = NumberFormat.decimalPattern();
  return '${formatter.format(value.round())} CDF';
}
