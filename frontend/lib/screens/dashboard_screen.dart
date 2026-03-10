import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import 'add_transaction_screen.dart';
import 'transaction_history_screen.dart';

import 'package:fl_chart/fl_chart.dart';
import '../services/chart_service.dart';
import '../models/chart_model.dart';

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

  @override
  void initState() {
    super.initState();
    loadDashboard();
    loadChart();
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
      appBar: AppBar(title: const Text("Dashboard")),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Open Add Transaction screen
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );

          // Refresh dashboard after returning
          loadDashboard();
        },
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text("Total Income"),
                trailing: Text(
                  "Rs $income",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                title: const Text("Total Expense"),
                trailing: Text(
                  "Rs $expense",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                title: const Text("Balance"),
                trailing: Text(
                  "Rs $balance",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              child: ListTile(
                title: const Text("Transaction History"),
                trailing: const Icon(Icons.arrow_forward),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionHistoryScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: chartData.map((data) {
                    return PieChartSectionData(
                      value: data.total,
                      title: data.category,
                      radius: 80,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
