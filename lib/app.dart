import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'controllers/admin_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/stats_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/user_controller.dart';
import 'routes/app_routes.dart';
import 'utils/constants.dart';

class BudgetFlowApp extends StatelessWidget {
  const BudgetFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => TransactionController()),
        ChangeNotifierProvider(create: (_) => CategoryController()),
        ChangeNotifierProvider(create: (_) => StatsController()),
        ChangeNotifierProvider(create: (_) => AdminController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: ThemeData(
              colorScheme:
                  ColorScheme.fromSeed(seedColor: AppConstants.seedColor),
              useMaterial3: true,
              textTheme: GoogleFonts.dmSansTextTheme(),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppConstants.seedColor,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.dmSansTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme,
              ),
            ),
            themeMode: themeController.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.login,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
