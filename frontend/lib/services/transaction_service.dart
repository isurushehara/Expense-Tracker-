import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/transaction_model.dart';
import 'auth_service.dart';

class TransactionService {

  static const String baseUrl = "http://localhost:5000/api";

  static Future<List<TransactionModel>> getTransactions() async {

    String? token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/transactions"),
      headers: {
        "Authorization": token ?? ""
      }
    );

    if(response.statusCode == 200){

      List data = jsonDecode(response.body);

      return data.map((e) => TransactionModel.fromJson(e)).toList();

    }else{

      return [];

    }

  }

}