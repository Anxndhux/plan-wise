class VehiclePreference {
  String userEmail;
  List<String> vehicleTypes;

  VehiclePreference({required this.userEmail, required this.vehicleTypes});

  Map<String, dynamic> toJson() => {
        "userEmail": userEmail,
        "vehicleTypes": vehicleTypes,
      };

  factory VehiclePreference.fromJson(Map<String, dynamic> json) {
    return VehiclePreference(
      userEmail: json['userEmail'],
      vehicleTypes: List<String>.from(json['vehicleTypes'] ?? []),
    );
  }
}
