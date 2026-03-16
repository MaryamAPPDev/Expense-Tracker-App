import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/settings/settings_viewmodel.dart';
import '../../features/transactions/transaction_viewmodel.dart';
import '../../features/categories/category_viewmodel.dart';
import '../../data/models/transaction_model.dart';
import 'package:uuid/uuid.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsVm, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle app theme'),
                secondary: const Icon(Icons.dark_mode),
                value: settingsVm.isDarkMode,
                onChanged: (val) => settingsVm.toggleDarkMode(val),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Monthly Budget Warning'),
                subtitle: Text('Current limit: \$${settingsVm.monthlyBudget.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  _showBudgetDialog(context, settingsVm);
                },
              ),
              const Divider(),
              Consumer<TransactionViewModel>(
                builder: (context, transVm, child) {
                  return ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Export to CSV'),
                    subtitle: const Text('Save your transactions locally'),
                    onTap: () async {
                      try {
                        final path = await transVm.exportToCSV();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Exported successfully to: $path')),
                          );
                        }
                      } catch (e) {
                         if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to export CSV')),
                          );
                        }
                      }
                    },
                  );
                }
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.bug_report, color: Colors.orange),
                title: const Text('Add Dummy Data'),
                subtitle: const Text('Populate app with testing data'),
                onTap: () => _addDummyData(context),
              )
            ],
          );
        },
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, SettingsViewModel vm) {
    final controller = TextEditingController(text: vm.monthlyBudget.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (\$)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null) {
                vm.setMonthlyBudget(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addDummyData(BuildContext context) {
    final transVm = Provider.of<TransactionViewModel>(context, listen: false);
    final catVm = Provider.of<CategoryViewModel>(context, listen: false);

    if (catVm.categories.isEmpty) return;
    
    final salaryCat = catVm.categories.firstWhere((c) => c.name == 'Salary', orElse: () => catVm.categories.first);
    final foodCat = catVm.categories.firstWhere((c) => c.name == 'Food', orElse: () => catVm.categories.first);
    final transCat = catVm.categories.firstWhere((c) => c.name == 'Transport', orElse: () => catVm.categories.first);
    
    final now = DateTime.now();
    transVm.addTransaction(TransactionModel(id: const Uuid().v4(), title: 'Monthly Salary', amount: 5000, isIncome: true, categoryId: salaryCat.id, date: now.subtract(const Duration(days: 10))));
    transVm.addTransaction(TransactionModel(id: const Uuid().v4(), title: 'Groceries', amount: 120.5, isIncome: false, categoryId: foodCat.id, date: now.subtract(const Duration(days: 2))));
    transVm.addTransaction(TransactionModel(id: const Uuid().v4(), title: 'Uber', amount: 35.0, isIncome: false, categoryId: transCat.id, date: now.subtract(const Duration(days: 1))));
    transVm.addTransaction(TransactionModel(id: const Uuid().v4(), title: 'Lunch', amount: 15.0, isIncome: false, categoryId: foodCat.id, date: now));

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dummy data added successfully!')));
  }
}
