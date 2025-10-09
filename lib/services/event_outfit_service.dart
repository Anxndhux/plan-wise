import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_outfit.dart';

class EventOutfitService {
  final String baseUrl = "http://10.0.2.2:8080/api/events";

  Future<bool> addEvent(EventOutfit event) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(event.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<EventOutfit>> getUserEvents(String userEmail) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userEmail'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => EventOutfit.fromJson(e)).toList();
    }
    return [];
  }
}
