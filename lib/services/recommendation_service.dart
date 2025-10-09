// lib/services/recommendation_service.dart

import 'dart:math';
import '../models/outfit.dart';
import '../models/vehicle.dart';
import '../models/profession.dart';
import '../models/recommendation.dart';

class RecommendationService {
  Recommendation generateRecommendation({
    required List<Outfit> outfits,
    required Profession? profession,
    required VehiclePreference? vehiclePref,
    required String weatherCondition,
  }) {
    final DateTime today = DateTime.now();
    final int weekday = today.weekday;

    List<String> dayMap = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    String todayStr = dayMap[weekday - 1];

    // Normalize weather condition
    String normalizedWeather(String cond) {
      cond = cond.toLowerCase();
      if (cond.contains('rain')) return 'rainy';
      if (cond.contains('cloud')) return 'cloudy';
      if (cond.contains('clear') || cond.contains('sun')) return 'sunny';
      if (cond.contains('hot')) return 'hot';
      if (cond.contains('cold')) return 'cold';
      return 'any';
    }

    final currentWeather = normalizedWeather(weatherCondition);
    final random = Random();

    if (outfits.isEmpty) {
      return Recommendation(
        outfit: Outfit(
          name: 'No outfits found',
          category: 'None',
          imageUrl: '',
          weather: '',
        ),
        vehicle: 'Public Transport',
        extras: [],
      );
    }

    bool isWorkDay = profession != null && profession.workDays.contains(todayStr);

    Outfit? selectedOutfit;

    // -------------------- UNIFORM --------------------
    if (profession != null &&
        profession.uniformOutfit != null &&
        profession.uniformOutfit!.trim().isNotEmpty &&
        profession.uniformDays.contains(todayStr)) {
      selectedOutfit = outfits.firstWhere(
  (o) => o.name.trim().toLowerCase() == profession.uniformOutfit!.trim().toLowerCase(),
  orElse: () => outfits[Random().nextInt(outfits.length)],
);
    }

    // -------------------- WORKDAY --------------------
    else if (profession != null && isWorkDay) {
      List<Outfit> allowed = outfits.where((o) {
        return profession.allowedOutfitCategories
                .map((c) => c.toLowerCase())
                .contains(o.category.toLowerCase()) &&
            (o.weather.toLowerCase() == currentWeather || o.weather.toLowerCase() == 'any');
      }).toList();

      // Fallback: pick from allowed categories ignoring weather
      if (allowed.isEmpty) {
        allowed = outfits.where((o) {
          return profession.allowedOutfitCategories
              .map((c) => c.toLowerCase())
              .contains(o.category.toLowerCase());
        }).toList();
      }

      selectedOutfit = allowed.isNotEmpty ? allowed[random.nextInt(allowed.length)] : null;
    }

    // -------------------- OFF-DUTY --------------------
    else if (profession != null && !isWorkDay) {
      List<Outfit> allowed = outfits.where((o) {
        return profession.offDutyPreferences
                .map((c) => c.toLowerCase())
                .contains(o.category.toLowerCase()) &&
            (o.weather.toLowerCase() == currentWeather || o.weather.toLowerCase() == 'any');
      }).toList();

      // Fallback: pick from off-duty categories ignoring weather
      if (allowed.isEmpty) {
        allowed = outfits.where((o) {
          return profession.offDutyPreferences
              .map((c) => c.toLowerCase())
              .contains(o.category.toLowerCase());
        }).toList();
      }

      selectedOutfit = allowed.isNotEmpty ? allowed[random.nextInt(allowed.length)] : null;
    }

    // -------------------- NO PROFESSION --------------------
    else {
      List<Outfit> allowed = outfits.where((o) =>
          o.weather.toLowerCase() == currentWeather || o.weather.toLowerCase() == 'any').toList();
      selectedOutfit = allowed.isNotEmpty ? allowed[random.nextInt(allowed.length)] : outfits[random.nextInt(outfits.length)];
    }

    // -------------------- VEHICLE --------------------
    String vehicle = "Public Transport";
    List<String> availableVehicles = vehiclePref?.vehicleTypes ?? [];

    if (currentWeather == 'rainy') {
      if (availableVehicles.contains('Car')) vehicle = 'Car';
      else if (availableVehicles.contains('Two wheeler')) vehicle = 'Two wheeler';
    } else {
      if (availableVehicles.contains('Two wheeler')) vehicle = 'Two wheeler';
      else if (availableVehicles.contains('Car')) vehicle = 'Car';
    }

    // -------------------- EXTRAS --------------------
    List<String> extras = [];
    if (currentWeather == 'rainy') {
      extras.add('Umbrella');
      if (vehicle == 'Two wheeler') extras.add('Raincoat');
    }
    if (currentWeather == 'sunny' || currentWeather == 'hot') {
      extras.add('Sunscreen');
    }

    // -------------------- FINAL --------------------
    return Recommendation(
      outfit: selectedOutfit ??
          Outfit(name: 'No outfit matched', category: 'None', imageUrl: '', weather: ''),
      vehicle: vehicle,
      extras: extras,
    );
  }
}
