import 'dart:io';
import 'package:flutter/material.dart';
import 'package:planwise_app/screens/profession_screen.dart';
import 'package:planwise_app/screens/vehicle_screen.dart';
import '../services/weather_service.dart';
import 'calendar_screen.dart';
import 'forecast_screen.dart';
import 'settings_screen.dart';
import 'tips_screen.dart';
import 'login_screen.dart';
import 'wardrobe_screen.dart';
import '../services/outfit_service.dart';
import '../services/profession_service.dart';
import '../services/vehicle_service.dart';
import '../services/recommendation_service.dart';
import '../models/recommendation.dart';
import '../models/profession.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  HomeScreen({required this.userName, required this.userEmail});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController cityController = TextEditingController();
  Map<String, dynamic> weatherData = {};
  bool isLoading = true;

  Recommendation? recommendation;

  @override
  void initState() {
    super.initState();
    fetchWeather('Kollam'); // default city
  }

  void fetchWeather(String city) async {
    setState(() => isLoading = true);
    final data = await WeatherService().getWeather(city);
    setState(() {
      weatherData = data;
      isLoading = false;
    });

    fetchRecommendation();
  }

  void fetchRecommendation() async {
    try {
      final outfits = await OutfitService().getUserOutfits(widget.userEmail);
      final professions = await ProfessionService().getProfessions(
        widget.userEmail,
      );

      Profession? profession;
      if (professions.isNotEmpty) {
        profession = professions
            .first; // Just take first profession, uniform logic is handled in RecommendationService
      }

      final vehiclePref = await VehicleService().getVehicle(widget.userEmail);
      final weatherCondition = (weatherData['condition'] ?? 'Clear').toString();

      final rec = RecommendationService().generateRecommendation(
        outfits: outfits,
        profession: profession,
        vehiclePref: vehiclePref,
        weatherCondition: weatherCondition,
      );

      print(
        "Recommendation: Outfit=${rec.outfit.name}, Uniform=${profession?.uniformOutfit}",
      );

      setState(() {
        recommendation = rec;
      });
    } catch (e) {
      print("Error generating recommendation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('PlanWise'),
        backgroundColor: const Color.fromARGB(255, 111, 148, 228),
      ),
      drawer: _buildDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCitySearch(),
                  SizedBox(height: 16),
                  _buildWeatherCard(),
                  SizedBox(height: 16),
                  if (recommendation != null) _buildRecommendationCard(),
                  SizedBox(height: 16),
                  _buildQuickButtons(),
                ],
              ),
            ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Text(
              'Welcome, ${widget.userName}!',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: Icon(Icons.checkroom),
            title: Text('Wardrobe Manager'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WardrobeScreen(userEmail: widget.userEmail),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.work),
            title: Text('Profession Preferences'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfessionScreen(userEmail: widget.userEmail),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.directions_car),
            title: Text('Vehicle Preferences'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VehicleScreen(userEmail: widget.userEmail),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySearch() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: cityController,
            decoration: InputDecoration(
              hintText: 'Enter city',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (cityController.text.isNotEmpty) {
              fetchWeather(cityController.text);
            }
          },
          child: Text('Search'),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.wb_sunny, size: 60, color: Colors.orangeAccent),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weatherData['condition'] ?? ''}, ${weatherData['temperature'] ?? ''}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('Weather today'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Recommendation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                recommendation!.outfit.imageUrl.isNotEmpty
                    ? Image.file(
                        File(recommendation!.outfit.imageUrl),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 40),
                      ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation!.outfit.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Category: ${recommendation!.outfit.category}"),
                      Text("Vehicle: ${recommendation!.vehicle}"),
                      Text("Extras: ${recommendation!.extras.join(', ')}"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _quickButton(Icons.calendar_today, 'Forecast', ForecastScreen()),
        _quickButton(
          Icons.event,
          'Calendar',
          CalendarScreen(userEmail: widget.userEmail),
        ),
        _quickButton(Icons.settings, 'Settings', SettingsScreen()),
        _quickButton(Icons.lightbulb, 'Tips', TipsScreen()),
      ],
    );
  }

  Widget _quickButton(IconData icon, String label, Widget screen) {
    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, size: 28, color: Colors.white),
          ),
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
