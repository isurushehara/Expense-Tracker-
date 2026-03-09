import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  double income = 0;
  double expense = 0;
  double balance = 0;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {

    String? token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("http://localhost:5000/api/dashboard"),
      headers: {
        "Authorization": token ?? ""
      }
    );

    if(response.statusCode == 200){

      final data = jsonDecode(response.body);

      setState(() {
        income = double.parse(data["total_income"].toString());
        expense = double.parse(data["total_expense"].toString());
        balance = double.parse(data["balance"].toString());
      });

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Dashboard"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            Card(
              child: ListTile(
                title: const Text("Total Income"),
                trailing: Text("Rs $income"),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Total Expense"),
                trailing: Text("Rs $expense"),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Balance"),
                trailing: Text("Rs $balance"),
              ),
            ),

          ],

        ),
      ),
    );
  }
}