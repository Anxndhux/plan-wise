// lib/screens/wardrobe_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../services/outfit_service.dart';
import 'AddOutfitScreen.dart';

class WardrobeScreen extends StatefulWidget {
  final String userEmail;
  const WardrobeScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final OutfitService _service = OutfitService();
  List<Outfit> _outfits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    setState(() => _isLoading = true);
    try {
      _outfits = await _service.getUserOutfits(widget.userEmail);
    } catch (e) {
      _outfits = [];
      print("Error fetching outfits: $e");
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wardrobe"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddOutfitScreen(userEmail: widget.userEmail),
                ),
              );
              _loadOutfits(); // refresh after adding
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _outfits.isEmpty
          ? const Center(child: Text("No outfits added"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _outfits.length,
              itemBuilder: (context, index) {
                final outfit = _outfits[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: outfit.imageUrl.isNotEmpty
                            ? Image.file(
                                File(outfit.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              outfit.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              outfit.category,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              "Weather: ${outfit.weather}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
