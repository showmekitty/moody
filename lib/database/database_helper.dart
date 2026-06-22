import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mood_entry.dart';

class DatabaseHelper {
  static Database? _database;

  Future<void> initDatabase() async {
    if (_database != null) return;
    _database = await _initDB();
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'moody.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE moods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mood INTEGER NOT NULL,
        note TEXT,
        tags TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertMood(MoodEntry entry) async {
    final db = _database!;
    return await db.insert('moods', entry.toMap());
  }

  Future<int> updateMood(MoodEntry entry) async {
    final db = _database!;
    return await db.update(
      'moods',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteMood(int id) async {
    final db = _database!;
    return await db.delete(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MoodEntry>> getAllMoods({String? searchTag}) async {
    final db = _database!;
    String query = 'SELECT * FROM moods';
    List<dynamic>? args;

    if (searchTag != null && searchTag.isNotEmpty) {
      query += ' WHERE tags LIKE ?';
      args = ['%$searchTag%'];
    }

    query += ' ORDER BY created_at DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<List<MoodEntry>> getMoodsByDateRange(
      DateTime start,
      DateTime end,
      ) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'moods',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<String> exportToText() async {
    final moods = await getAllMoods();
    StringBuffer buffer = StringBuffer();
    buffer.writeln('=== MOODY - ДНЕВНИК НАСТРОЕНИЯ ===');
    buffer.writeln('');

    for (var entry in moods) {
      String date =
          '${entry.createdAt.day}.${entry.createdAt.month}.${entry.createdAt.year}';
      buffer.writeln('$date | ${entry.moodEmoji} ${entry.moodText}');
      if (entry.note != null && entry.note!.isNotEmpty) {
        buffer.writeln('  📝 ${entry.note}');
      }
      if (entry.tags != null && entry.tags!.isNotEmpty) {
        buffer.writeln('  🏷️ ${entry.tags}');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  Future<Map<String, dynamic>> getStats() async {
    final db = _database!;

    final countResult =
    await db.rawQuery('SELECT COUNT(*) as total FROM moods');
    int total = Sqflite.firstIntValue(countResult) ?? 0;

    final avgResult =
    await db.rawQuery('SELECT AVG(mood) as avg_mood FROM moods');
    double avgMood = (avgResult.first['avg_mood'] as num?)?.toDouble() ?? 0.0;

    final distribution = await db.rawQuery(
        'SELECT mood, COUNT(*) as count FROM moods GROUP BY mood ORDER BY mood');

    final tagsResult = await db.rawQuery(
        'SELECT tags FROM moods WHERE tags IS NOT NULL AND tags != ""');
    Map<String, int> tagCount = {};
    for (var row in tagsResult) {
      String? tags = row['tags'] as String?;
      if (tags != null) {
        for (String tag in tags.split(',')) {
          tag = tag.trim();
          if (tag.isNotEmpty) {
            tagCount[tag] = (tagCount[tag] ?? 0) + 1;
          }
        }
      }
    }

    var topTags = tagCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'total': total,
      'avgMood': avgMood,
      'distribution': distribution,
      'topTags': topTags.take(5).toList(),
    };
  }
}