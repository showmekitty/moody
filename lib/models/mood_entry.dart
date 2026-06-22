class MoodEntry {
  final int? id;
  final int mood;
  final String? note;
  final String? tags;
  final DateTime createdAt;

  MoodEntry({
    this.id,
    required this.mood,
    this.note,
    this.tags,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood,
      'note': note,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      mood: map['mood'],
      note: map['note'],
      tags: map['tags'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  String get moodEmoji {
    switch (mood) {
      case 1:
        return '😭';
      case 2:
        return '😟';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😍';
      default:
        return '😐';
    }
  }

  String get moodText {
    switch (mood) {
      case 1:
        return 'Ужасно';
      case 2:
        return 'Плохо';
      case 3:
        return 'Нормально';
      case 4:
        return 'Хорошо';
      case 5:
        return 'Отлично';
      default:
        return 'Нормально';
    }
  }
}