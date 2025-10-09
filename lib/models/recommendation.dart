// lib/models/recommendation.dart
import 'package:planwise_app/models/outfit.dart';

class Recommendation {
  final Outfit outfit;
  final String vehicle;
  final List<String> extras; // e.g., ["Umbrella", "Sunscreen"]

  Recommendation({
    required this.outfit,
    required this.vehicle,
    required this.extras,
  });
}
