import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NearbyScreen extends StatefulWidget {
  final double lat;
  final double lon;

  NearbyScreen({required this.lat, required this.lon});

  @override
  _NearbyScreenState createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  List<dynamic> places = [];
  bool isLoading = false;
  TextEditingController _searchController = TextEditingController();

  final String apiKey =
      'AIzaSyBWyKyGkm1iSWAjZ9o9gos-gvqBiR884Ss'; // <-- replace with your API key

  @override
  void initState() {
    super.initState();
    fetchNearbyPlaces(); // fetch default nearby places
  }

  Future<void> fetchNearbyPlaces({String type = 'restaurant'}) async {
    setState(() {
      isLoading = true;
    });

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${widget.lat},${widget.lon}'
        '&radius=1500'
        '&type=$type'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          places = data['results'];
          isLoading = false;
        });
      } else {
        print("Error fetching places: ${response.body}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _searchNearbyByPlaceName(
    String placeName, {
    String type = 'restaurant',
  }) async {
    setState(() {
      isLoading = true;
    });

    final String query = Uri.encodeComponent(placeName);
    final String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json'
        '?query=$query'
        '&type=$type'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          places = data['results'];
          isLoading = false;
        });
      } else {
        print("Error searching places: ${response.body}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openMaps(String placeName) async {
    final String query = Uri.encodeComponent(placeName);
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$query';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open Google Maps')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Places'),
        backgroundColor: Color.fromARGB(255, 111, 148, 228),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search place (city, landmark...)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      _searchNearbyByPlaceName(_searchController.text);
                    }
                  },
                  child: Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : places.isEmpty
                ? Center(child: Text('No nearby places found.'))
                : ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: place['icon'] != null
                              ? Image.network(
                                  place['icon'],
                                  width: 40,
                                  height: 40,
                                )
                              : Icon(Icons.place),
                          title: Text(place['name'] ?? ''),
                          subtitle: Text(
                            place['formatted_address'] ??
                                place['vicinity'] ??
                                '',
                          ),
                          trailing: Icon(Icons.navigation),
                          onTap: () => _openMaps(place['name']),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
