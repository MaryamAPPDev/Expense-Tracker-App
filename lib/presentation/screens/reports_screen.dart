import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../features/transactions/transaction_viewmodel.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: Consumer<TransactionViewModel>(
        builder: (context, vm, child) {
          final expenses = vm.transactions.where((t) => !t.isIncome).toList();
          
          if (expenses.isEmpty) {
            return const Center(child: Text('No expense data available for reports.'));
          }

          // Group by category
          final Map<String, double> categoryTotals = {};
          for (var t in expenses) {
            final catName = vm.getCategory(t.categoryId)?.name ?? 'Unknown';
            categoryTotals[catName] = (categoryTotals[catName] ?? 0) + t.amount;
          }

          final List<PieChartSectionData> sections = [];
          int colorIndex = 0;
          final colors = [
            Colors.blue, Colors.red, Colors.green, Colors.orange, 
            Colors.purple, Colors.teal, Colors.indigo,
          ];

          categoryTotals.forEach((key, value) {
            sections.add(
              PieChartSectionData(
                color: colors[colorIndex % colors.length],
                value: value,
                title: key,
                radius: 60,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            );
            colorIndex++;
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Expense by Category',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Total Expenses: \$${vm.totalExpense.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
