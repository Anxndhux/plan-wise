import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'login_screen.dart';
import 'forecast_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'tips_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  HomeScreen({required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController cityController = TextEditingController();

  Map<String, dynamic> weatherData = {};
  bool isLoading = true;
  List<String> activities = [];
  String outfitSuggestion = '';

  @override
  void initState() {
    super.initState();
    fetchWeather('Kollam'); // default city
  }

  void fetchWeather(String city) async {
    setState(() {
      isLoading = true;
    });

    final data = await WeatherService().getWeather(city);

    // Generate outfit & activities based on temperature
    String outfit;
    double temp =
        double.tryParse(data['temperature']?.replaceAll('°C', '') ?? '25') ??
        25;

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
      appBar: AppBar(
        title: Text('PlanWise Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
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
                  Text(
                    'Welcome, ${widget.userName}!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Here are your daily suggestions and forecasts.'),
                  SizedBox(height: 20),

                  // City Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityController,
                          decoration: InputDecoration(
                            hintText: 'Enter city name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                  SizedBox(height: 20),

                  // Weather Card
                  Card(
                    elevation: 4,
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
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${weatherData['condition'] ?? ''}, ${weatherData['temperature'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text('Check your outfit and activities!'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Outfit Suggestion Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.checkroom,
                            size: 60,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Outfit Suggestion',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(outfitSuggestion),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Activity Carousel
                  Container(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: activities
                          .map((activity) => activityCard(activity))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Quick Access Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      quickAccessButton(
                        context,
                        Icons.calendar_today,
                        'Forecast',
                      ),
                      quickAccessButton(context, Icons.event, 'Calendar'),
                      quickAccessButton(context, Icons.settings, 'Settings'),
                      quickAccessButton(context, Icons.lightbulb, 'Tips'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // Activity card helper
  Widget activityCard(String title) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 120,
        padding: EdgeInsets.all(12),
        child: Center(child: Text(title, textAlign: TextAlign.center)),
      ),
    );
  }

  // Quick Access Button helper
  Widget quickAccessButton(BuildContext context, IconData icon, String label) {
    Widget? screen;

    switch (label) {
      case 'Forecast':
        screen = ForecastScreen();
        break;
      case 'Calendar':
        screen = CalendarScreen();
        break;
      case 'Settings':
        screen = SettingsScreen();
        break;
      case 'Tips':
        screen = TipsScreen();
        break;
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            if (screen != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => screen!),
              );
            }
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, size: 30, color: Colors.white),
          ),
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
