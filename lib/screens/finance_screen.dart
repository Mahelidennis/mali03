import 'package:flutter/material.dart';
import '../expenses_screen.dart';
import '../income_management_screen.dart';
import '../financial_reports_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Finance',
          style: TextStyle(
            color: Color(0xFF181114),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFEE2B8D),
          labelColor: const Color(0xFFEE2B8D),
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.receipt_long, size: 20),
              text: 'Expenses',
            ),
            Tab(
              icon: Icon(Icons.account_balance_wallet, size: 20),
              text: 'Income',
            ),
            Tab(
              icon: Icon(Icons.bar_chart, size: 20),
              text: 'Reports',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExpensesScreen(),
          IncomeManagementScreen(),
          FinancialReportsScreen(),
        ],
      ),
    );
  }
}
