import 'package:flutter/material.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/budget_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepo;
  final BudgetRepository _budgetRepo;

  bool _isDarkMode = false;
  double _monthlyBudget = 0.0;

  bool get isDarkMode => _isDarkMode;
  double get monthlyBudget => _monthlyBudget;

  SettingsViewModel(this._settingsRepo, this._budgetRepo) {
    _loadSettings();
  }

  void _loadSettings() {
    _isDarkMode = _settingsRepo.isDarkMode;
    _monthlyBudget = _budgetRepo.monthlyBudget;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await _settingsRepo.setDarkMode(value);
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double value) async {
    _monthlyBudget = value;
    await _budgetRepo.setMonthlyBudget(value);
    notifyListeners();
  }
}
