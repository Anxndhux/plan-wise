import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';

class VehicleService {
  final String baseUrl = 'http://10.0.2.2:8080/api/vehicles';

  // Save or update vehicle preferences
  Future<bool> saveVehicle(VehiclePreference vehicle) async {
    final response = await http.post(
      Uri.parse('$baseUrl/save'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(vehicle.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Fetch vehicle preferences for a user
  Future<VehiclePreference?> getVehicle(String userEmail) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userEmail'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Ensure 'vehicleTypes' exists
      if (data['vehicleTypes'] == null) {
        data['vehicleTypes'] = [];
      }
      return VehiclePreference.fromJson(data);
    }
    return null;
  }
}
