import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetflow/l10n/app_localizations.dart';

import '../../controllers/user_controller.dart';
import '../admin/admin_dashboard.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';
import 'transactions_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<UserController>().isAdmin;

    final tabs = <Widget>[
      HomeScreen(
        onViewAllTransactions: () => setState(() => _currentIndex = 1),
      ),
      const TransactionsScreen(),
      const CategoriesScreen(),
      const StatsScreen(),
      const ProfileScreen(),
      if (isAdmin) const AdminDashboard(),
    ];

    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: const Icon(Icons.home), label: AppLocalizations.of(context)!.navHome),
      BottomNavigationBarItem(
          icon: const Icon(Icons.swap_horiz), label: AppLocalizations.of(context)!.navTransactions),
      const BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined), label: 'Catégories'),
      BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart), label: AppLocalizations.of(context)!.navStats),
      BottomNavigationBarItem(icon: const Icon(Icons.person), label: AppLocalizations.of(context)!.navProfile),
      if (isAdmin)
        BottomNavigationBarItem(
            icon: const Icon(Icons.admin_panel_settings), label: AppLocalizations.of(context)!.navAdmin),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: items,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
