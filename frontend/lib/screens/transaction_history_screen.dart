import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await TransactionService.getTransactions();

    setState(() {
      transactions = data;
    });
  }

  Future<void> deleteTransaction(String id) async {
    String? token = await AuthService.getToken();

    final response = await http.delete(
      Uri.parse("http://localhost:5000/api/transactions/$id"),
      headers: {"Authorization": token ?? ""},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Transaction deleted")));

      loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),

      body: ListView.builder(
        itemCount: transactions.length,

        itemBuilder: (context, index) {
          final t = transactions[index];

          return ListTile(
            leading: Icon(
              t.type == "income" ? Icons.arrow_downward : Icons.arrow_upward,
              color: t.type == "income" ? Colors.green : Colors.red,
            ),

            title: Text(t.description),

            subtitle: Text(t.date),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Rs ${t.amount}",
                  style: TextStyle(
                    color: t.type == "income" ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),

                  onPressed: () {
                    deleteTransaction(t.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
