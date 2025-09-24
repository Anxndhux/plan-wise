import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'calendar_screen.dart';
import 'forecast_screen.dart';
import 'settings_screen.dart';
import 'tips_screen.dart';
import 'login_screen.dart';
import 'wardrobe_screen.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WardrobeScreen(userEmail: widget.userEmail),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('PlanWise'),
        backgroundColor: const Color.fromARGB(255, 111, 148, 228),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
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
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            size: 60,
                            color: Colors.orangeAccent,
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${weatherData['condition'] ?? ''}, ${weatherData['temperature'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text('Weather today'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _quickButton(
                        Icons.calendar_today,
                        'Forecast',
                        ForecastScreen(),
                      ),
                      _quickButton(Icons.event, 'Calendar', CalendarScreen()),
                      _quickButton(
                        Icons.settings,
                        'Settings',
                        SettingsScreen(),
                      ),
                      _quickButton(Icons.lightbulb, 'Tips', TipsScreen()),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _quickButton(IconData icon, String label, Widget screen) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          },
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
