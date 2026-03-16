import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../features/transactions/transaction_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import 'add_transaction_screen.dart';

enum TransactionFilter { all, today, week, month }

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String _searchQuery = '';
  TransactionFilter _filter = TransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: SegmentedButton<TransactionFilter>(
                  segments: const [
                    ButtonSegment(value: TransactionFilter.all, label: Text('All')),
                    ButtonSegment(value: TransactionFilter.today, label: Text('Today')),
                    ButtonSegment(value: TransactionFilter.week, label: Text('Week')),
                    ButtonSegment(value: TransactionFilter.month, label: Text('Month')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (set) {
                    setState(() => _filter = set.first);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Consumer<TransactionViewModel>(
        builder: (context, vm, child) {
          final formatCurrency = NumberFormat.simpleCurrency();
          
          var transactions = vm.searchTransactions(_searchQuery);
          
          final now = DateTime.now();
          if (_filter == TransactionFilter.today) {
            transactions = transactions.where((t) => t.date.year == now.year && t.date.month == now.month && t.date.day == now.day).toList();
          } else if (_filter == TransactionFilter.week) {
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            transactions = transactions.where((t) => t.date.isAfter(startOfWeek) || t.date.isAtSameMomentAs(startOfWeek)).toList();
          } else if (_filter == TransactionFilter.month) {
            transactions = transactions.where((t) => t.date.year == now.year && t.date.month == now.month).toList();
          }

          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              final category = vm.getCategory(t.categoryId);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      category != null ? IconData(category.iconCodePoint, fontFamily: 'MaterialIcons') : Icons.help_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${category?.name ?? 'Unknown'} • ${DateFormat.yMMMd().format(t.date)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${t.isIncome ? '+' : '-'}${formatCurrency.format(t.amount)}',
                        style: TextStyle(
                          color: t.isIncome ? AppColors.income : AppColors.expense,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
                        onPressed: () => vm.deleteTransaction(t.id),
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddTransactionScreen(transactionToEdit: t)
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
