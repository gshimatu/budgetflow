import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row;
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
        body: Center(child: Text(l10n.signInToSeeStats)),
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
                  child: Text(
                    AppLocalizations.of(context)!.statsNoTransactions,
                  ),
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
                    _SummaryRow(
                      summary: summary,
                      currency: currency,
                      rate: rate,
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle(
                      title: AppLocalizations.of(context)!.expensesBreakdown,
                    ),
                    const SizedBox(height: 12),
                    _PieChartCard(
                      data: expensesByCategory,
                      currency: currency,
                      rate: rate,
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle(
                      title: AppLocalizations.of(context)!.monthlyEvolution,
                    ),
                    const SizedBox(height: 12),
                    _MonthlyChartCard(data: monthlySeries),
                    const SizedBox(height: 20),
                    _SectionTitle(
                      title: AppLocalizations.of(
                        context,
                      )!.dailyExpenseTrendTitle,
                    ),
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

    final start = DateTime(
      picked.start.year,
      picked.start.month,
      picked.start.day,
    );
    final end = DateTime(
      picked.end.year,
      picked.end.month,
      picked.end.day,
      23,
      59,
      59,
      999,
    );

    final filtered = _latestTransactions
        .where((tx) => !tx.date.isBefore(start) && !tx.date.isAfter(end))
        .toList();

    if (filtered.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportNoData)));
      return;
    }

    final summary = _buildSummary(filtered);
    final monthly = _buildMonthlySummary(filtered);

    final proceed = await _showExportPreview(
      context: context,
      l10n: l10n,
      range: picked,
      summaryRows: monthly.length + 5,
      detailsRows: filtered.length,
    );
    if (!proceed) return;

    try {
      final dir = await _getExportDirectory();
      await dir.create(recursive: true);
      final safeStart = DateFormat('yyyyMMdd').format(start);
      final safeEnd = DateFormat('yyyyMMdd').format(end);
      final now = DateTime.now();

      // Generate Excel files
      final summaryBytes = _generateSummaryExcel(
        l10n: l10n,
        locale: locale,
        range: picked,
        summary: summary,
        monthly: monthly,
        currency: _currency,
        rate: _rate,
        generatedAt: now,
        transactionCount: filtered.length,
      );

      final detailsBytes = _generateDetailsExcel(
        l10n: l10n,
        locale: locale,
        transactions: filtered,
        currency: _currency,
        rate: _rate,
        generatedAt: now,
      );

      final summaryFile = File(
        '${dir.path}/budgetflow_summary_${safeStart}_${safeEnd}.xlsx',
      );
      final detailsFile = File(
        '${dir.path}/budgetflow_details_${safeStart}_${safeEnd}.xlsx',
      );

      await summaryFile.writeAsBytes(summaryBytes);
      await detailsFile.writeAsBytes(detailsBytes);

      await Share.shareXFiles([
        XFile(summaryFile.path),
        XFile(detailsFile.path),
      ], text: l10n.exportCsv);

      if (!mounted) return;
      await _showExportSaved(context: context, l10n: l10n, directory: dir);
    } catch (e, st) {
      debugPrint('Export failed (file save): $e');
      debugPrint(st.toString());
      try {
        final safeStart = DateFormat('yyyyMMdd').format(start);
        final safeEnd = DateFormat('yyyyMMdd').format(end);
        final now = DateTime.now();

        // Generate Excel files for sharing
        final summaryBytes = _generateSummaryExcel(
          l10n: l10n,
          locale: locale,
          range: picked,
          summary: summary,
          monthly: monthly,
          currency: _currency,
          rate: _rate,
          generatedAt: now,
          transactionCount: filtered.length,
        );

        final detailsBytes = _generateDetailsExcel(
          l10n: l10n,
          locale: locale,
          transactions: filtered,
          currency: _currency,
          rate: _rate,
          generatedAt: now,
        );

        await Share.shareXFiles([
          XFile.fromData(
            Uint8List.fromList(summaryBytes),
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            name: 'budgetflow_summary_${safeStart}_${safeEnd}.xlsx',
          ),
          XFile.fromData(
            Uint8List.fromList(detailsBytes),
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            name: 'budgetflow_details_${safeStart}_${safeEnd}.xlsx',
          ),
        ], text: l10n.exportCsv);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportSaved)));
      } catch (e2, st2) {
        debugPrint('Export failed (share fallback): $e2');
        debugPrint(st2.toString());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.exportFailed} ${e2.toString()}')),
        );
      }
    }
  }

  Future<bool> _showExportPreview({
    required BuildContext context,
    required AppLocalizations l10n,
    required DateTimeRange range,
    required int summaryRows,
    required int detailsRows,
  }) async {
    final locale = Localizations.localeOf(context).toString();
    final rangeLabel =
        '${DateFormat('yyyy-MM-dd', locale).format(range.start)} ? ${DateFormat('yyyy-MM-dd', locale).format(range.end)}';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.exportPreviewTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n.exportPreviewRange}: $rangeLabel'),
              const SizedBox(height: 8),
              Text('${l10n.exportPreviewSummary}: $summaryRows'),
              Text('${l10n.exportPreviewDetails}: $detailsRows'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.exportCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.exportStartExport),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> _showExportSaved({
    required BuildContext context,
    required AppLocalizations l10n,
    required Directory directory,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.exportSaved),
          content: Text('${l10n.exportSaveLocation}: ${directory.path}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await OpenFilex.open(directory.path);
              },
              child: Text(l10n.exportOpenFolder),
            ),
          ],
        );
      },
    );
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
  const _SummaryRow({
    required this.summary,
    required this.currency,
    required this.rate,
  });

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
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _PieChartCard extends StatelessWidget {
  const _PieChartCard({
    required this.data,
    required this.currency,
    required this.rate,
  });

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
  const _DailyPoint({required this.label, required this.expense});

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
    (index) =>
        _DailyPoint(label: (index + 1).toString(), expense: totals[index]),
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
      return _EmptyCard(message: AppLocalizations.of(context)!.noDataForPeriod);
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
                _LegendItem(
                  label: AppLocalizations.of(context)!.income,
                  color: Color(0xFF33CC33),
                ),
                _LegendItem(
                  label: AppLocalizations.of(context)!.expenses,
                  color: Color(0xFFFC7520),
                ),
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
                _LegendItem(
                  label: AppLocalizations.of(context)!.expenses,
                  color: Color(0xFFFC7520),
                ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
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
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
  const _ChartLegend({required this.items, required this.note});

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
  final actualValue = value * rate;
  final formatter = NumberFormat('#,##0.00', 'en_US');
  return '${formatter.format(actualValue)} $currency';
}

class _MonthlySummary {
  _MonthlySummary({required this.income, required this.expense});

  final double income;
  final double expense;

  double get balance => income - expense;
}

Map<String, _MonthlySummary> _buildMonthlySummary(
  List<TransactionModel> items,
) {
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

List<int> _generateSummaryExcel({
  required AppLocalizations l10n,
  required String locale,
  required DateTimeRange range,
  required _SummaryData summary,
  required Map<String, _MonthlySummary> monthly,
  required String currency,
  required double rate,
  required DateTime generatedAt,
  required int transactionCount,
}) {
  // Create a new Excel workbook
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];

  int row = 1;

  // Title row
  sheet
      .getRangeByIndex(row, 1)
      .setText('📊 BudgetFlow - ${l10n.exportSummarySheet}');
  final titleCell = sheet.getRangeByIndex(row, 1);
  titleCell.cellStyle.backColor = '#1F4788';
  titleCell.cellStyle.fontColor = '#FFFFFF';
  titleCell.cellStyle.bold = true;
  titleCell.cellStyle.fontSize = 14;
  row++;
  row++;

  // Generation info
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss', locale);
  sheet
      .getRangeByIndex(row, 1)
      .setText('Generated: ${dateFormat.format(generatedAt)}');
  sheet.getRangeByIndex(row, 1).cellStyle.fontSize = 9;
  sheet.getRangeByIndex(row, 1).cellStyle.italic = true;
  row++;
  sheet.getRangeByIndex(row, 1).setText('Generated by BudgetFlow');
  sheet.getRangeByIndex(row, 1).cellStyle.fontSize = 9;
  sheet.getRangeByIndex(row, 1).cellStyle.italic = true;
  row++;
  row++;

  // Date range
  sheet.getRangeByIndex(row, 1).setText(l10n.exportStart);
  sheet.getRangeByIndex(row, 1).cellStyle.bold = true;
  sheet
      .getRangeByIndex(row, 2)
      .setText(DateFormat('yyyy-MM-dd', locale).format(range.start));
  row++;

  sheet.getRangeByIndex(row, 1).setText(l10n.exportEnd);
  sheet.getRangeByIndex(row, 1).cellStyle.bold = true;
  sheet
      .getRangeByIndex(row, 2)
      .setText(DateFormat('yyyy-MM-dd', locale).format(range.end));
  row++;

  sheet.getRangeByIndex(row, 1).setText(l10n.exportTransactionsCount);
  sheet.getRangeByIndex(row, 1).cellStyle.bold = true;
  sheet.getRangeByIndex(row, 2).setNumber(transactionCount.toDouble());
  row++;
  row++;

  // Summary totals
  sheet.getRangeByIndex(row, 1).setText(l10n.exportTotalIncome);
  sheet.getRangeByIndex(row, 1).cellStyle.bold = true;
  sheet.getRangeByIndex(row, 2).setNumber(summary.totalIncome * rate);
  sheet.getRangeByIndex(row, 3).setText(currency);
  row++;

  sheet.getRangeByIndex(row, 1).setText(l10n.exportTotalExpense);
  sheet.getRangeByIndex(row, 1).cellStyle.bold = true;
  sheet.getRangeByIndex(row, 2).setNumber(summary.totalExpense * rate);
  sheet.getRangeByIndex(row, 3).setText(currency);
  row++;

  sheet.getRangeByIndex(row, 1).setText(l10n.exportBalance);
  sheet.getRangeByIndex(row, 1).cellStyle.bold = true;
  sheet.getRangeByIndex(row, 2).setNumber(summary.balance * rate);
  sheet.getRangeByIndex(row, 3).setText(currency);
  row++;
  row++;

  // Monthly breakdown header
  sheet.getRangeByIndex(row, 1).setText(l10n.exportMonthLabel);
  sheet.getRangeByIndex(row, 2).setText(l10n.exportTotalIncome);
  sheet.getRangeByIndex(row, 3).setText(l10n.exportTotalExpense);
  sheet.getRangeByIndex(row, 4).setText(l10n.exportBalance);

  for (int col = 1; col <= 4; col++) {
    final cell = sheet.getRangeByIndex(row, col);
    cell.cellStyle.bold = true;
    cell.cellStyle.backColor = '#4472C4';
    cell.cellStyle.fontColor = '#FFFFFF';
  }
  row++;

  // Monthly data
  final sortedMonths = monthly.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  for (final entry in sortedMonths) {
    final parts = entry.key.split('-');
    final monthDate = DateTime(int.parse(parts[0]), int.parse(parts[1]));

    sheet
        .getRangeByIndex(row, 1)
        .setText(DateFormat('MMM yyyy', locale).format(monthDate));
    sheet.getRangeByIndex(row, 2).setNumber(entry.value.income * rate);
    sheet.getRangeByIndex(row, 3).setNumber(entry.value.expense * rate);
    sheet.getRangeByIndex(row, 4).setNumber(entry.value.balance * rate);
    row++;
  }

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  return bytes;
}

List<int> _generateDetailsExcel({
  required AppLocalizations l10n,
  required String locale,
  required List<TransactionModel> transactions,
  required String currency,
  required double rate,
  required DateTime generatedAt,
}) {
  // Create a new Excel workbook
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];

  int row = 1;

  // Title row
  sheet
      .getRangeByIndex(row, 1)
      .setText('📋 BudgetFlow - ${l10n.exportDetailsSheet}');
  final titleCell = sheet.getRangeByIndex(row, 1);
  titleCell.cellStyle.backColor = '#1F4788';
  titleCell.cellStyle.fontColor = '#FFFFFF';
  titleCell.cellStyle.bold = true;
  titleCell.cellStyle.fontSize = 14;
  row++;
  row++;

  // Generation info
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss', locale);
  sheet
      .getRangeByIndex(row, 1)
      .setText('Generated: ${dateFormat.format(generatedAt)}');
  sheet.getRangeByIndex(row, 1).cellStyle.fontSize = 9;
  sheet.getRangeByIndex(row, 1).cellStyle.italic = true;
  row++;
  sheet.getRangeByIndex(row, 1).setText('Generated by BudgetFlow');
  sheet.getRangeByIndex(row, 1).cellStyle.fontSize = 9;
  sheet.getRangeByIndex(row, 1).cellStyle.italic = true;
  row++;
  row++;

  // Table header
  final headers = [
    l10n.exportDate,
    l10n.exportTime,
    l10n.exportType,
    l10n.exportCategory,
    l10n.exportAmount,
    l10n.exportCurrency,
    l10n.exportOriginalCurrency,
    l10n.exportRate,
    l10n.exportNote,
  ];

  for (int col = 0; col < headers.length; col++) {
    final cell = sheet.getRangeByIndex(row, col + 1);
    cell.setText(headers[col]);
    cell.cellStyle.bold = true;
    cell.cellStyle.backColor = '#4472C4';
    cell.cellStyle.fontColor = '#FFFFFF';
  }
  row++;

  // Data rows
  final sorted = List<TransactionModel>.from(transactions)
    ..sort((a, b) => b.date.compareTo(a.date));
  for (final tx in sorted) {
    final dateLabel = DateFormat('yyyy-MM-dd', locale).format(tx.date);
    final timeLabel = DateFormat('HH:mm:ss', locale).format(tx.date);
    final typeLabel = _isIncome(tx.type) ? l10n.income : l10n.expenses;
    final categoryLabel = tx.categoryName?.isNotEmpty == true
        ? tx.categoryName!
        : tx.categoryId;

    sheet.getRangeByIndex(row, 1).setText(dateLabel);
    sheet.getRangeByIndex(row, 2).setText(timeLabel);
    sheet.getRangeByIndex(row, 3).setText(typeLabel);
    sheet.getRangeByIndex(row, 4).setText(categoryLabel);
    sheet.getRangeByIndex(row, 5).setNumber(tx.amount * rate);
    sheet.getRangeByIndex(row, 6).setText(currency);
    sheet.getRangeByIndex(row, 7).setText(tx.originalCurrency ?? '');
    sheet.getRangeByIndex(row, 8).setText(rate.toStringAsFixed(4));
    sheet.getRangeByIndex(row, 9).setText(tx.note ?? '');

    row++;
  }

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  return bytes;
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
