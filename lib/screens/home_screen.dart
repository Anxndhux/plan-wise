import 'dart:io';
import 'package:flutter/material.dart';
import 'package:planwise_app/screens/profession_screen.dart';
import 'package:planwise_app/screens/vehicle_screen.dart';
import '../services/weather_service.dart';
import 'calendar_screen.dart';
import 'forecast_screen.dart';
import 'settings_screen.dart';
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
    fetchWeather('Kollam');
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
        profession = professions.first;
      }

      final vehiclePref = await VehicleService().getVehicle(widget.userEmail);
      final weatherCondition = (weatherData['condition'] ?? 'Clear').toString();

      final rec = RecommendationService().generateRecommendation(
        outfits: outfits,
        profession: profession,
        vehiclePref: vehiclePref,
        weatherCondition: weatherCondition,
      );

      setState(() {
        recommendation = rec;
      });
    } catch (e) {
      print("Error generating recommendation: $e");
    }
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('rain')) return Icons.umbrella;
    if (condition.contains('cloud')) return Icons.cloud;
    if (condition.contains('snow')) return Icons.ac_unit;
    if (condition.contains('thunder') || condition.contains('storm'))
      return Icons.flash_on;
    if (condition.contains('wind')) return Icons.air;
    return Icons.wb_sunny;
  }

  Color _getWeatherColor(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('rain')) return Color(0xFF74B9FF);
    if (condition.contains('cloud')) return Color(0xFFB2BEC3);
    if (condition.contains('snow')) return Color(0xFF81ECEC);
    if (condition.contains('thunder') || condition.contains('storm'))
      return Color(0xFF636E72);
    if (condition.contains('wind')) return Color(0xFFE17055);
    return Color.fromARGB(255, 208, 178, 42);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text(
          'PlanWise',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF6F94E4),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(),
      body: isLoading
          ? _buildLoadingScreen()
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildCitySearch(),
                  SizedBox(height: 24),
                  _buildWeatherCard(),
                  SizedBox(height: 24),
                  if (recommendation != null) _buildRecommendationCard(),
                  SizedBox(height: 24),
                  _buildQuickButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6F94E4)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your daily plan...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6F94E4), Color(0xFF4A6FC1)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: Color(0xFF6F94E4),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    widget.userEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.checkroom,
              title: 'Wardrobe Manager',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WardrobeScreen(userEmail: widget.userEmail),
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.work,
              title: 'Profession Preferences',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfessionScreen(userEmail: widget.userEmail),
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.directions_car,
              title: 'Vehicle Preferences',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VehicleScreen(userEmail: widget.userEmail),
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.card_travel,
              title: 'Trip Planner',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.3), height: 20),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildCitySearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: cityController,
                decoration: InputDecoration(
                  hintText: 'Search for a city...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF6F94E4)),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6F94E4), Color(0xFF4A6FC1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  if (cityController.text.isNotEmpty) {
                    fetchWeather(cityController.text);
                  }
                },
                icon: Icon(Icons.search, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    final condition = weatherData['condition']?.toString() ?? 'Clear';
    final temperature = weatherData['temperature']?.toString() ?? 'N/A';
    final weatherColor = _getWeatherColor(condition);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [weatherColor.withOpacity(0.8), weatherColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: weatherColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getWeatherIcon(condition),
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    temperature,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Current Weather',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Today's Smart Recommendation",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Outfit Image
                Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: recommendation!.outfit.imageUrl.isNotEmpty
                        ? Image.file(
                            File(recommendation!.outfit.imageUrl),
                            width: 100,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.checkroom,
                                size: 36,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          recommendation!.outfit.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildRecommendationDetail(
                        'Category',
                        recommendation!.outfit.category,
                      ),
                      _buildRecommendationDetail(
                        'Vehicle',
                        recommendation!.vehicle,
                      ),
                      if (recommendation!.extras.isNotEmpty)
                        _buildRecommendationDetail(
                          'Extras',
                          recommendation!.extras.join(', '),
                        ),
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

  Widget _buildRecommendationDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _quickButton(
                Icons.today,
                'Forecast',
                ForecastScreen(),
                Colors.orange,
              ),
              _quickButton(
                Icons.event,
                'Calendar',
                CalendarScreen(userEmail: widget.userEmail),
                Colors.green,
              ),
              _quickButton(
                Icons.settings,
                'Settings',
                SettingsScreen(),
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickButton(IconData icon, String label, Widget screen, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            ),
            icon: Icon(icon, size: 24, color: Colors.white),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
