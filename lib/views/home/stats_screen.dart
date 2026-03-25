import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:budgetflow/l10n/app_localizations.dart';

import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int? _selectedMonth;
  int? _selectedYear;
  List<TransactionModel> _latestTransactions = const [];
  String _currency = 'CDF';
  double _rate = 1.0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.statsTitle)),
        body: Center(
          child: Text(l10n.signInToSeeStats),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(l10n.statsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: l10n.exportCsv,
            onPressed: () => _exportCsv(context),
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
          final rate = (prefs['rate'] as num?)?.toDouble() ?? 1.0;
          _currency = currency;
          _rate = rate;
          return StreamBuilder<List<TransactionModel>>(
            stream: FirestoreService().watchTransactions(user.uid),
            builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final transactions = snapshot.data ?? [];
          _latestTransactions = transactions;
          if (transactions.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.statsNoTransactions),
            );
          }

          final years = _availableYears(transactions);
          _selectedYear ??= years.first;
          _selectedMonth ??= DateTime.now().month;

          final filtered = _filterByMonth(
            transactions,
            _selectedYear!,
            _selectedMonth!,
          );
          final summary = _buildSummary(filtered);
          final expensesByCategory = _groupExpensesByCategory(filtered);
          final monthlySeries = _buildMonthlySeries(
            transactions,
            _selectedYear!,
            _selectedMonth!,
          );
          final dailyExpenseSeries = _buildDailyExpenseSeries(
            transactions,
            _selectedYear!,
            _selectedMonth!,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FilterRow(
                  selectedMonth: _selectedMonth!,
                  selectedYear: _selectedYear!,
                  years: years,
                  onMonthChanged: (value) {
                    setState(() => _selectedMonth = value);
                  },
                  onYearChanged: (value) {
                    setState(() => _selectedYear = value);
                  },
                ),
                const SizedBox(height: 16),
                _SummaryRow(summary: summary, currency: currency, rate: rate),
                const SizedBox(height: 20),
                _SectionTitle(title: AppLocalizations.of(context)!.expensesBreakdown),
                const SizedBox(height: 12),
                _PieChartCard(data: expensesByCategory, currency: currency, rate: rate),
                const SizedBox(height: 20),
                _SectionTitle(title: AppLocalizations.of(context)!.monthlyEvolution),
                const SizedBox(height: 12),
                _MonthlyChartCard(data: monthlySeries),
                const SizedBox(height: 20),
                _SectionTitle(title: AppLocalizations.of(context)!.dailyExpenseTrendTitle),
                const SizedBox(height: 12),
                _DailyTrendChartCard(data: dailyExpenseSeries),
              ],
            ),
          );
        },
      );
        },
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      helpText: l10n.exportSelectRange,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month, now.day),
      ),
    );
    if (!mounted) return;
    if (picked == null) return;

    final start = DateTime(picked.start.year, picked.start.month, picked.start.day);
    final end = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59, 999);

    final filtered = _latestTransactions
        .where((tx) => !tx.date.isBefore(start) && !tx.date.isAfter(end))
        .toList();

    if (filtered.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportNoData)),
      );
      return;
    }

    final summary = _buildSummary(filtered);
    final monthly = _buildMonthlySummary(filtered);

    final summaryCsv = _buildSummaryCsv(
      l10n,
      locale,
      picked,
      summary,
      monthly,
      _currency,
      _rate,
      filtered.length,
    );

    final detailsCsv = _buildDetailsCsv(
      l10n,
      locale,
      filtered,
      _currency,
      _rate,
    );

    try {
      final dir = await _getExportDirectory();
      await dir.create(recursive: true);
      final safeStart = DateFormat('yyyyMMdd').format(start);
      final safeEnd = DateFormat('yyyyMMdd').format(end);
      final summaryFile = File('${dir.path}/budgetflow_summary_${safeStart}_${safeEnd}.csv');
      final detailsFile = File('${dir.path}/budgetflow_details_${safeStart}_${safeEnd}.csv');
      await summaryFile.writeAsString('\uFEFF$summaryCsv');
      await detailsFile.writeAsString('\uFEFF$detailsCsv');
      await Share.shareXFiles(
        [XFile(summaryFile.path), XFile(detailsFile.path)],
        text: l10n.exportCsv,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportSaved)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportFailed)),
      );
    }
  }
}

List<int> _availableYears(List<TransactionModel> items) {
  final years = items.map((e) => e.date.year).toSet().toList()..sort();
  if (years.isEmpty) {
    years.add(DateTime.now().year);
  }
  return years;
}

List<TransactionModel> _filterByMonth(
  List<TransactionModel> items,
  int year,
  int month,
) {
  return items
      .where((e) => e.date.year == year && e.date.month == month)
      .toList();
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

List<_MonthlyPoint> _buildMonthlySeries(
  List<TransactionModel> items,
  int year,
  int selectedMonth,
) {
  final months = List.generate(
    6,
    (index) => DateTime(year, selectedMonth - (5 - index)),
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

String _monthKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}';

bool _isIncome(String type) {
  final value = type.toLowerCase();
  return value.contains('revenu') || value == 'income';
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selectedMonth,
    required this.selectedYear,
    required this.years,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  final int selectedMonth;
  final int selectedYear;
  final List<int> years;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  @override
  Widget build(BuildContext context) {
    final monthNames = List.generate(
      12,
      (index) => DateFormat.MMM().format(DateTime(2000, index + 1)),
    );
    return Row(
      children: [
        Expanded(
          child: _DropdownCard<int>(
            label: AppLocalizations.of(context)!.monthLabel,
            value: selectedMonth,
            items: List.generate(
              12,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text(monthNames[index]),
              ),
            ),
            onChanged: onMonthChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DropdownCard<int>(
            label: AppLocalizations.of(context)!.yearLabel,
            value: selectedYear,
            items: years
                .map(
                  (year) => DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  ),
                )
                .toList(),
            onChanged: onYearChanged,
          ),
        ),
      ],
    );
  }
}

class _DropdownCard<T> extends StatelessWidget {
  const _DropdownCard({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: (value) {
            if (value == null) return;
            onChanged(value);
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary, required this.currency, required this.rate});

  final _SummaryData summary;
  final String currency;
  final double rate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: AppLocalizations.of(context)!.income,
            value: _formatMoney(summary.totalIncome, currency, rate),
            color: const Color(0xFF33CC33),
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: AppLocalizations.of(context)!.expenses,
            value: _formatMoney(summary.totalExpense, currency, rate),
            color: const Color(0xFFFC7520),
            icon: Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: AppLocalizations.of(context)!.balanceLabel,
            value: _formatMoney(summary.balance, currency, rate),
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
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
  const _PieChartCard({required this.data, required this.currency, required this.rate});

  final Map<String, double> data;
  final String currency;
  final double rate;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _EmptyCard(
        message: AppLocalizations.of(context)!.noExpenseThisMonth,
      );
    }
    final total = data.values.fold<double>(0, (a, b) => a + b);
    final colors = const [
      Color(0xFF33CC33),
      Color(0xFF0BC1DE),
      Color(0xFFFC7520),
      Color(0xFF6366F1),
      Color(0xFFF97316),
      Color(0xFF22C55E),
    ];

    final entries = data.entries.toList();
    final sections = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = item.value;
      final percent = total == 0 ? 0 : (value / total) * 100;
      final color = colors[index % colors.length];
      return PieChartSectionData(
        color: color,
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
        color: Theme.of(context).colorScheme.surface,
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
          _PieLegend(
            entries: entries,
            colors: colors,
            total: total,
            currency: currency,
            rate: rate,
          ),
        ],
      ),
    );
  }
}


class _DailyPoint {
  const _DailyPoint({
    required this.label,
    required this.expense,
  });

  final String label;
  final double expense;
}

List<_DailyPoint> _buildDailyExpenseSeries(
  List<TransactionModel> items,
  int year,
  int month,
) {
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final totals = List<double>.filled(daysInMonth, 0);

  for (final item in items) {
    if (_isIncome(item.type)) continue;
    if (item.date.year == year && item.date.month == month) {
      final index = item.date.day - 1;
      totals[index] += item.amount;
    }
  }

  return List.generate(
    daysInMonth,
    (index) => _DailyPoint(
      label: (index + 1).toString(),
      expense: totals[index],
    ),
  );
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
    final hasData = data.any((item) => item.income > 0 || item.expense > 0);
    if (!hasData) {
      return _EmptyCard(
        message: AppLocalizations.of(context)!.noDataForPeriod,
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        height: 260,
        child: Column(
          children: [
            _ChartLegend(
              items: [
                _LegendItem(label: AppLocalizations.of(context)!.income, color: Color(0xFF33CC33)),
                _LegendItem(label: AppLocalizations.of(context)!.expenses, color: Color(0xFFFC7520)),
              ],
              note: AppLocalizations.of(context)!.monthlyEvolutionNote,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
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
          ],
        ),
      ),
    );
  }
}


class _DailyTrendChartCard extends StatelessWidget {
  const _DailyTrendChartCard({required this.data});

  final List<_DailyPoint> data;

  @override
  Widget build(BuildContext context) {
    final hasData = data.any((item) => item.expense > 0);
    if (!hasData) {
      return _EmptyCard(
        message: AppLocalizations.of(context)!.noExpenseThisMonth,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        height: 260,
        child: Column(
          children: [
            _ChartLegend(
              items: [
                _LegendItem(label: AppLocalizations.of(context)!.expenses, color: Color(0xFFFC7520)),
              ],
              note: AppLocalizations.of(context)!.dailyEvolutionNote,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map(
                            (entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.expense,
                            ),
                          )
                          .toList(),
                      isCurved: false,
                      color: const Color(0xFFFC7520),
                      barWidth: 2.5,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolygonChartCard extends StatelessWidget {
  const _PolygonChartCard({required this.data});

  final List<_MonthlyPoint> data;

  @override
  Widget build(BuildContext context) {
    final hasData = data.any((item) => item.income > 0 || item.expense > 0);
    if (!hasData) {
      return _EmptyCard(
        message: AppLocalizations.of(context)!.noDataForPeriod,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        height: 260,
        child: Column(
          children: [
            _ChartLegend(
              items: [
                _LegendItem(label: AppLocalizations.of(context)!.income, color: Color(0xFF33CC33)),
                _LegendItem(label: AppLocalizations.of(context)!.expenses, color: Color(0xFFFC7520)),
              ],
              note: 'Courbes polygonales pour comparer les tendances.',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map(
                            (entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.income,
                            ),
                          )
                          .toList(),
                      isCurved: false,
                      color: const Color(0xFF33CC33),
                      barWidth: 2.5,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map(
                            (entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.expense,
                            ),
                          )
                          .toList(),
                      isCurved: false,
                      color: const Color(0xFFFC7520),
                      barWidth: 2.5,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
        ),
      ),
    );
  }
}

class _PieLegend extends StatelessWidget {
  const _PieLegend({
    required this.entries,
    required this.colors,
    required this.total,
    required this.currency,
    required this.rate,
  });

  final List<MapEntry<String, double>> entries;
  final List<Color> colors;
  final double total;
  final String currency;
  final double rate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final percent = total == 0 ? 0 : (item.value / total) * 100;
        final color = colors[index % colors.length];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(item.key)),
              Text(
                '${_formatMoney(item.value, currency, rate)}  (${percent.toStringAsFixed(0)}%)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({
    required this.items,
    required this.note,
  });

  final List<_LegendItem> items;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        Text(
          note,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _LegendItem {
  _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;
}

String _formatMoney(double value, String currency, double rate) {
  final formatter = NumberFormat.decimalPattern();
  return '${formatter.format((value * rate).round())} $currency';
}

class _MonthlySummary {
  _MonthlySummary({required this.income, required this.expense});

  final double income;
  final double expense;

  double get balance => income - expense;
}

Map<String, _MonthlySummary> _buildMonthlySummary(List<TransactionModel> items) {
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

  final keys = <String>{...income.keys, ...expense.keys}.toList()..sort();
  final Map<String, _MonthlySummary> result = {};
  for (final key in keys) {
    result[key] = _MonthlySummary(
      income: income[key] ?? 0,
      expense: expense[key] ?? 0,
    );
  }
  return result;
}

String _buildSummaryCsv(
  AppLocalizations l10n,
  String locale,
  DateTimeRange range,
  _SummaryData summary,
  Map<String, _MonthlySummary> monthly,
  String currency,
  double rate,
  int count,
) {
  final rows = <List<String>>[];
  rows.add([l10n.exportSummarySheet]);
  rows.add([l10n.exportStart, DateFormat('yyyy-MM-dd', locale).format(range.start)]);
  rows.add([l10n.exportEnd, DateFormat('yyyy-MM-dd', locale).format(range.end)]);
  rows.add([l10n.exportTotalIncome, _formatMoney(summary.totalIncome, currency, rate)]);
  rows.add([l10n.exportTotalExpense, _formatMoney(summary.totalExpense, currency, rate)]);
  rows.add([l10n.exportBalance, _formatMoney(summary.balance, currency, rate)]);
  rows.add([l10n.exportTransactionsCount, count.toString()]);
  rows.add([]);
  rows.add([
    l10n.exportMonthLabel,
    l10n.exportTotalIncome,
    l10n.exportTotalExpense,
    l10n.exportBalance,
  ]);
  for (final entry in monthly.entries) {
    final parts = entry.key.split('-');
    final monthDate = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    rows.add([
      DateFormat('MMM yyyy', locale).format(monthDate),
      _formatMoney(entry.value.income, currency, rate),
      _formatMoney(entry.value.expense, currency, rate),
      _formatMoney(entry.value.balance, currency, rate),
    ]);
  }
  return _toCsv(rows);
}

String _buildDetailsCsv(
  AppLocalizations l10n,
  String locale,
  List<TransactionModel> items,
  String currency,
  double rate,
) {
  final rows = <List<String>>[];
  rows.add([
    l10n.exportDate,
    l10n.exportTime,
    l10n.exportType,
    l10n.exportCategory,
    l10n.exportAmount,
    l10n.exportCurrency,
    l10n.exportOriginalCurrency,
    l10n.exportRate,
    l10n.exportNote,
  ]);

  final sorted = List<TransactionModel>.from(items)
    ..sort((a, b) => b.date.compareTo(a.date));

  for (final tx in sorted) {
    final dateLabel = DateFormat('yyyy-MM-dd', locale).format(tx.date);
    final timeLabel = DateFormat('HH:mm', locale).format(tx.date);
    final typeLabel = _isIncome(tx.type) ? l10n.income : l10n.expenses;
    final categoryLabel = tx.categoryName?.isNotEmpty == true
        ? tx.categoryName!
        : tx.categoryId;
    rows.add([
      dateLabel,
      timeLabel,
      typeLabel,
      categoryLabel,
      _formatMoney(tx.amount, currency, rate),
      currency,
      tx.originalCurrency ?? '',
      rate.toStringAsFixed(4),
      tx.note ?? '',
    ]);
  }

  return _toCsv(rows);
}

String _toCsv(List<List<String>> rows) {
  return rows.map((row) => row.map(_csvEscape).join(',')).join('\n');
}

String _csvEscape(String value) {
  final needsQuotes = value.contains(',') || value.contains('\n') || value.contains('"');
  if (!needsQuotes) return value;
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}

Future<Directory> _getExportDirectory() async {
  if (kIsWeb) {
    return getTemporaryDirectory();
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final dir = await getDownloadsDirectory();
    if (dir != null) {
      return Directory('${dir.path}${Platform.pathSeparator}BudgetFlow');
    }
  }
  if (Platform.isAndroid) {
    final dir = await getExternalStorageDirectory();
    if (dir != null) {
      return Directory('${dir.path}${Platform.pathSeparator}BudgetFlow');
    }
  }
  return getApplicationDocumentsDirectory();
}




