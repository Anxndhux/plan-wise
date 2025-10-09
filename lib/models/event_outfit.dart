class EventOutfit {
  String userEmail;
  String eventName;
  DateTime eventDate;
  String outfitName;
  String outfitType;
  DateTime? reminderDate;

  EventOutfit({
    required this.userEmail,
    required this.eventName,
    required this.eventDate,
    required this.outfitName,
    required this.outfitType,
    this.reminderDate,
  });

  factory EventOutfit.fromJson(Map<String, dynamic> json) {
    return EventOutfit(
      userEmail: json['userEmail'],
      eventName: json['eventName'],
      eventDate: DateTime.parse(json['eventDate']),
      outfitName: json['outfitName'],
      outfitType: json['outfitType'],
      reminderDate: json['reminderDate'] != null
          ? DateTime.parse(json['reminderDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'outfitName': outfitName,
      'outfitType': outfitType,
      'reminderDate': reminderDate?.toIso8601String(),
    };
  }
}
