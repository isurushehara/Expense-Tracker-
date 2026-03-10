import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Transaction History"),
      ),

      body: ListView.builder(

        itemCount: transactions.length,

        itemBuilder: (context, index){

          final t = transactions[index];

          return ListTile(

            leading: Icon(
              t.type == "income" ? Icons.arrow_downward : Icons.arrow_upward,
              color: t.type == "income" ? Colors.green : Colors.red,
            ),

            title: Text(t.description),

            subtitle: Text(t.date),

            trailing: Text(
              "Rs ${t.amount}",
              style: TextStyle(
                color: t.type == "income" ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold
              ),
            ),

          );

        },

      ),

    );

  }

}