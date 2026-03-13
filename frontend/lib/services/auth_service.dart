import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://localhost:5000/api";

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data["token"];

      // Save token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      return true;
    } else {
      return false;
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await http.get(
      Uri.parse("$baseUrl/auth/profile"),
      headers: {"Authorization": token},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["user"] as Map<String, dynamic>;
    }

    return null;
  }
}
