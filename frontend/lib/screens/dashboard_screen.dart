import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import 'add_transaction_screen.dart';
import 'transaction_history_screen.dart';

import 'package:fl_chart/fl_chart.dart';
import '../services/chart_service.dart';
import '../models/chart_model.dart';

import '../services/budget_service.dart';
import '../models/budget_model.dart';
import 'set_budget_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double income = 0;
  double expense = 0;
  double balance = 0;

  List<ChartData> chartData = [];
  List<Budget> budgets = [];
  int touchedIndex = -1;

  final List<Color> chartColors = [
    const Color(0xFF6366F1),
    const Color(0xFF818CF8),
    const Color(0xFFA5B4FC),
    const Color(0xFFC7D2FE),
    const Color(0xFFE0E7FF),
    const Color(0xFFEEF2FF),
  ];

  @override
  void initState() {
    super.initState();
    loadDashboard();
    loadChart();
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    final data = await BudgetService.getBudgets();
    setState(() {
      budgets = data;
    });
  }

  Future<void> loadDashboard() async {
    String? token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse("http://localhost:5000/api/dashboard"),
      headers: {"Authorization": token ?? ""},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        income = double.parse(data["total_income"].toString());
        expense = double.parse(data["total_expense"].toString());
        balance = double.parse(data["balance"].toString());
      });
    }
  }

  Future<void> loadChart() async {
    final data = await ChartService.getExpenseChart();
    setState(() {
      chartData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          loadDashboard();
          loadChart();
          loadBudgets();
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await loadDashboard();
          await loadChart();
          await loadBudgets();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 30,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Financial Summary Cards
                      ..._buildFinancialSummary(),

                      const SizedBox(height: 25),

                      // Transaction History Link
                      _buildNavigationCard(
                        "Transaction History",
                        Icons.history,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TransactionHistoryScreen(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Pie Chart
                      _buildPieChart(),

                      const SizedBox(height: 40),

                      // Budgets Section
                      ..._buildBudgetsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFinancialSummary() {
    return [
      _buildSummaryCard("Total Income", "Rs $income", Colors.green),
      const SizedBox(height: 15),
      _buildSummaryCard("Total Expense", "Rs $expense", Colors.red),
      const SizedBox(height: 15),
      _buildSummaryCard("Balance", "Rs $balance", Colors.blue),
    ];
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1)),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: chartData.isEmpty
          ? const Center(child: Text("No expense data for chart."))
          : PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: List.generate(chartData.length, (i) {
                  final isTouched = i == touchedIndex;
                  final fontSize = isTouched ? 18.0 : 14.0;
                  final radius = isTouched ? 60.0 : 50.0;
                  final data = chartData[i];
                  final percentage = (data.total / expense * 100)
                      .toStringAsFixed(1);

                  return PieChartSectionData(
                    color: chartColors[i % chartColors.length],
                    value: data.total,
                    title: '${data.category}\n$percentage%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffffffff),
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 2),
                      ],
                    ),
                  );
                }),
              ),
            ),
    );
  }

  List<Widget> _buildBudgetsSection() {
    return [
      const Text(
        "Budgets",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      const SizedBox(height: 15),
      SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SetBudgetScreen()),
            );
            loadBudgets();
          },
          child: const Text(
            "Set New Budget",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      budgets.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No budgets set yet. Tap above to create one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: budgets.map((b) {
                double progress = b.spent / b.limit;
                if (progress.isNaN || progress.isInfinite) progress = 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Rs ${b.spent.toStringAsFixed(2)} / Rs ${b.limit.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress > 1 ? 1 : progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.8
                              ? Colors.redAccent
                              : (progress > 0.5
                                    ? Colors.orangeAccent
                                    : const Color(0xFF6366F1)),
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    ];
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
