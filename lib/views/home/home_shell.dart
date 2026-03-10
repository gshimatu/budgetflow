import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      const HomeScreen(),
      const TransactionsScreen(),
      const CategoriesScreen(),
      const StatsScreen(),
      const ProfileScreen(),
      if (isAdmin) const AdminDashboard(),
    ];

    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz), label: 'Transactions'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined), label: 'Catégories'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart), label: 'Stats'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      if (isAdmin)
        const BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
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
