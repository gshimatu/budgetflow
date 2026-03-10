import 'package:flutter/material.dart';

import '../views/admin/admin_dashboard.dart';
import '../views/admin/global_stats_screen.dart';
import '../views/admin/manage_categories_screen.dart';
import '../views/admin/manage_users_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/home/home_shell.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static const String adminDashboard = '/admin';
  static const String adminCategories = '/admin/categories';
  static const String adminUsers = '/admin/users';
  static const String adminStats = '/admin/stats';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeShell());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case adminCategories:
        return MaterialPageRoute(builder: (_) => const ManageCategoriesScreen());
      case adminUsers:
        return MaterialPageRoute(builder: (_) => const ManageUsersScreen());
      case adminStats:
        return MaterialPageRoute(builder: (_) => const GlobalStatsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
