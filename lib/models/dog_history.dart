class DogHistory {
  final DateTime date;
  final String mood;
  final bool wasFed;

  DogHistory({
    required this.date,
    required this.mood,
    required this.wasFed,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mood': mood,
      'wasFed': wasFed,
    };
  }

  factory DogHistory.fromJson(Map<String, dynamic> json) {
    return DogHistory(
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String? ?? 'Happy 😊',
      wasFed: json['wasFed'] as bool? ?? false,
    );
  }
}
