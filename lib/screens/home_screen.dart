import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'calendar_screen.dart';
import 'forecast_screen.dart';
import 'settings_screen.dart';
import 'tips_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  HomeScreen({required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController cityController = TextEditingController();
  Map<String, dynamic> weatherData = {};
  List<String> activities = [];
  String outfitSuggestion = '';
  String dailyTip = 'Stay hydrated!';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeather('Kollam');
  }

  void fetchWeather(String city) async {
    setState(() => isLoading = true);
    final data = await WeatherService().getWeather(city);
    double temp =
        double.tryParse(data['temperature']?.replaceAll('°C', '') ?? '25') ??
        25;

    String outfit;
    if (temp >= 28) {
      outfit = 'Light T-shirt and shorts';
      activities = ['Jogging', 'Outdoor Yoga', 'Cycling', 'Swimming'];
    } else if (temp >= 20) {
      outfit = 'T-shirt and jeans';
      activities = ['Reading', 'Walking', 'Yoga', 'Cafe visit'];
    } else {
      outfit = 'Sweater and pants';
      activities = ['Indoor exercises', 'Reading', 'Movie', 'Board Games'];
    }

    setState(() {
      weatherData = data;
      outfitSuggestion = outfit;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('PlanWise'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Greeting
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Hello, ${widget.userName}!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // City input & search
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

                  // Weather Card
                  _buildCard(
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

                  SizedBox(height: 16),

                  // Outfit Card
                  _buildCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.checkroom,
                          size: 50,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Outfit Suggestion',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(outfitSuggestion),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Activity Carousel
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: activities
                          .map((act) => _activityCard(act))
                          .toList(),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Daily Tip Card
                  _buildCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          size: 40,
                          color: Colors.yellow[700],
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            dailyTip,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Quick Access Buttons
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

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: EdgeInsets.all(16), child: child),
    );
  }

  Widget _activityCard(String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 120,
        padding: EdgeInsets.all(12),
        child: Center(child: Text(title, textAlign: TextAlign.center)),
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
