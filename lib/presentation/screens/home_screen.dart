import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/transactions/transaction_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import 'add_transaction_screen.dart';
import 'all_transactions_screen.dart';
import 'category_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const ReportsScreen(),
    const CategoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.category), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllTransactionsScreen()),
              );
            },
          )
        ],
      ),
      body: Consumer<TransactionViewModel>(
        builder: (context, vm, child) {
          final formatCurrency = NumberFormat.simpleCurrency();
          return RefreshIndicator(
            onRefresh: () async {}, // Handle refresh if needed
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBalanceCard(context, vm, formatCurrency),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AllTransactionsScreen()),
                        );
                      },
                      child: const Text('View All'),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                if (vm.recentTransactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No transactions yet. Add some!'),
                    ),
                  )
                else
                  ...vm.recentTransactions.map((t) {
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
                        subtitle: Text(DateFormat.yMMMd().format(t.date)),
                        trailing: Text(
                          '${t.isIncome ? '+' : '-'}${formatCurrency.format(t.amount)}',
                          style: TextStyle(
                            color: t.isIncome ? AppColors.income : AppColors.expense,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => AddTransactionScreen(transactionToEdit: t)
                          ));
                        },
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, TransactionViewModel vm, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            format.format(vm.totalBalance),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIncomeExpenseStat('Income', vm.totalIncome, Icons.arrow_downward, AppColors.income, format),
              _buildIncomeExpenseStat('Expense', vm.totalExpense, Icons.arrow_upward, AppColors.expense, format),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseStat(String label, double amount, IconData icon, Color color, NumberFormat format) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white24,
          radius: 16,
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text(
              format.format(amount),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }
}
