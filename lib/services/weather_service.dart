import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey =
      '9e719067f72a4af5ad09b724945dfa2c'; // Replace with your OpenWeather API key

  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'temperature': data['main']['temp'].toString() + '°C',
          'condition': data['weather'][0]['main'],
        };
      } else {
        return {'temperature': '--', 'condition': 'Unknown'};
      }
    } catch (e) {
      return {'temperature': '--', 'condition': 'Error'};
    }
  }
}
