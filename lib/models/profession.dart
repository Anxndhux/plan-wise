class Profession {
  String userEmail;
  String professionName;
  String professionType;
  bool hasUniform;
  String? uniformOutfit;
  List<String> uniformDays; // ✅ NEW
  List<String> workDays;
  List<String> allowedOutfitCategories;
  List<String> offDutyPreferences;

  Profession({
    required this.userEmail,
    required this.professionName,
    required this.professionType,
    required this.hasUniform,
    this.uniformOutfit,
    required this.uniformDays, // ✅
    required this.workDays,
    required this.allowedOutfitCategories,
    required this.offDutyPreferences,
  });

  Map<String, dynamic> toJson() => {
        'userEmail': userEmail,
        'professionName': professionName,
        'professionType': professionType,
        'hasUniform': hasUniform,
        'uniformOutfit': uniformOutfit,
        'uniformDays': uniformDays, // ✅
        'workDays': workDays,
        'allowedOutfitCategories': allowedOutfitCategories,
        'offDutyPreferences': offDutyPreferences,
      };

  factory Profession.fromJson(Map<String, dynamic> json) {
    return Profession(
      userEmail: json['userEmail'],
      professionName: json['professionName'],
      professionType: json['professionType'],
      hasUniform: json['hasUniform'] == 1 || json['hasUniform'] == true,
      uniformOutfit: json['uniformOutfit'],
      uniformDays: List<String>.from(json['uniformDays'] ?? []), // ✅
      workDays: List<String>.from(json['workDays']),
      allowedOutfitCategories: List<String>.from(json['allowedOutfitCategories']),
      offDutyPreferences: List<String>.from(json['offDutyPreferences']),
    );
  }
}
