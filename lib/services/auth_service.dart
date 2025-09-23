import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8080/api/auth';

  Future<String> registerUser({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String dob,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'gender': gender,
          'dob': dob,
          'phone': phone,
        }),
      );

      // Decode JSON if backend returns JSON, otherwise fallback
      try {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Registration successful';
      } catch (_) {
        return response.body;
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      try {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Login successful';
      } catch (_) {
        return response.body;
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
