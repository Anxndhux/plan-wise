// lib/model/outfit.dart
class Outfit {
  final String name;
  final String category;
  final String imageUrl;
  final String weather;

  Outfit({
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.weather,
  });

  Map<String, dynamic> toJson(String userEmail) => {
    "userEmail": userEmail,
    "name": name,
    "category": category,
    "imagePath": imageUrl,
    "weather": weather,
  };

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
    name: json['name'],
    category: json['category'],
    imageUrl: json['imagePath'],
    weather: json['weather'],
  );
}
