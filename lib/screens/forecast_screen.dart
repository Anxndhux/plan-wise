import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';

class ForecastScreen extends StatefulWidget {
  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final WeatherService _weatherService = WeatherService();
  List<Map<String, dynamic>> _forecast = [];
  bool _isLoading = true;
  String? _error;

  double? lat;
  double? lon;

  @override
  void initState() {
    super.initState();
    fetchLocationAndForecast();
  }

  /// Step 1: Get user location
  Future<void> fetchLocationAndForecast() async {
    try {
      Position position = await _determinePosition();
      lat = position.latitude;
      lon = position.longitude;

      // Step 2: Fetch forecast for current location
      final data = await _weatherService.get5DayForecast(lat!, lon!);
      setState(() {
        _forecast = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Forecast Error: $e');
    }
  }

  /// Request location permission and get position
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat.E().format(date);
  }

  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.wb_cloudy;
      case 'rain':
        return Icons.beach_access;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'drizzle':
        return Icons.grain;
      default:
        return Icons.wb_sunny_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('5-Day Forecast')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _forecast.length,
              itemBuilder: (context, index) {
                final day = _forecast[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      getWeatherIcon(day['condition']),
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      '${formatDate(day['dt'])} - ${day['condition']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(day['temp'], style: TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
    );
  }
}
