import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/hive/hive_service.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/categories_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/transactions_repository.dart';
import 'features/categories/category_viewmodel.dart';
import 'features/settings/settings_viewmodel.dart';
import 'features/transactions/transaction_viewmodel.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  final settingsRepo = SettingsRepository();
  final budgetRepo = BudgetRepository();
  final categoriesRepo = CategoriesRepository();
  final transactionsRepo = TransactionsRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(settingsRepo, budgetRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryViewModel(categoriesRepo),
        ),
        ChangeNotifierProxyProvider<CategoryViewModel, TransactionViewModel>(
          create: (context) => TransactionViewModel(
            transactionsRepo,
            Provider.of<CategoryViewModel>(context, listen: false),
          ),
          update: (context, categoryViewModel, previous) => previous ?? TransactionViewModel(
            transactionsRepo,
            categoryViewModel,
          ),
        ),
      ],
      child: const SmartExpenseTrackerApp(),
    ),
  );
}

class SmartExpenseTrackerApp extends StatelessWidget {
  const SmartExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Smart Expense Tracker',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
