import 'dog_history.dart';

class Dog {
  final String id;
  final String name;
  final String mood;
  final String notes;
  final DateTime? lastFedTime;
  final String healthStatus;
  final int feedingInterval;
  final List<DogHistory> history;
  
  final String? imagePath;
  final double? weight;
  final DateTime? birthDate;
  final DateTime? lastWalkedTime;
  final int walkInterval;

  Dog({
    required this.id,
    required this.name,
    required this.mood,
    this.notes = '',
    this.lastFedTime,
    this.healthStatus = 'Healthy',
    this.feedingInterval = 6,
    this.history = const [],
    this.imagePath,
    this.weight,
    this.birthDate,
    this.lastWalkedTime,
    this.walkInterval = 8,
  });

  bool get needsFeeding {
    if (lastFedTime == null) return true;
    return DateTime.now().difference(lastFedTime!).inHours >= feedingInterval;
  }

  bool get needsWalking {
    if (lastWalkedTime == null) return true;
    return DateTime.now().difference(lastWalkedTime!).inHours >= walkInterval;
  }

  Map<String, int> generateMonthlyReport() {
    int happyDays = 0;
    int sickDays = 0;
    int lazyDays = 0;
    int missedFeedings = 0;

    for (var entry in history) {
      if (entry.mood.contains('Happy')) {
        happyDays++;
      } else if (entry.mood.contains('Sick')) {
        sickDays++;
      } else if (entry.mood.contains('Lazy')) {
        lazyDays++;
      }

      if (!entry.wasFed) {
        missedFeedings++;
      }
    }

    return {
      'Happy Days': happyDays,
      'Sick Days': sickDays,
      'Lazy Days': lazyDays,
      'Missed Feedings': missedFeedings,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mood': mood,
      'notes': notes,
      'lastFedTime': lastFedTime?.toIso8601String(),
      'healthStatus': healthStatus,
      'feedingInterval': feedingInterval,
      'history': history.map((h) => h.toJson()).toList(),
      'imagePath': imagePath,
      'weight': weight,
      'birthDate': birthDate?.toIso8601String(),
      'lastWalkedTime': lastWalkedTime?.toIso8601String(),
      'walkInterval': walkInterval,
    };
  }

  factory Dog.fromJson(Map<String, dynamic> json) {
    var historyList = json['history'] as List<dynamic>? ?? [];
    final now = DateTime.now();

    return Dog(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mood: json['mood'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      lastFedTime: json['lastFedTime'] != null ? DateTime.parse(json['lastFedTime'] as String) : null,
      healthStatus: json['healthStatus'] as String? ?? 'Healthy',
      feedingInterval: json['feedingInterval'] as int? ?? 6,
      history: historyList
          .map((h) => DogHistory.fromJson(h as Map<String, dynamic>))
          .where((h) => now.difference(h.date).inDays <= 30)
          .toList(),
      imagePath: json['imagePath'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate'] as String) : null,
      lastWalkedTime: json['lastWalkedTime'] != null ? DateTime.parse(json['lastWalkedTime'] as String) : null,
      walkInterval: json['walkInterval'] as int? ?? 8,
    );
  }
}
