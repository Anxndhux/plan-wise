import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profession.dart';

class ProfessionService {
  final String baseUrl = 'http://10.0.2.2:8080/api/professions';

  Future<bool> saveProfession(Profession prof) async {
    final response = await http.post(
      Uri.parse('$baseUrl/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(prof.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<Profession>> getProfessions(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$email'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Profession.fromJson(e)).toList();
    }
    return [];
  }
}
