import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class StatsScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const StatsScreen({super.key, required this.dbHelper});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  List<Map<String, dynamic>> _weeklyMoods = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadWeeklyMoods();
  }

  Future<void> _loadStats() async {
    final stats = await widget.dbHelper.getStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _loadWeeklyMoods() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final moods =
    await widget.dbHelper.getMoodsByDateRange(weekAgo, now);

    Map<String, List<double>> grouped = {};
    for (var m in moods) {
      String day = DateFormat('EEE', 'ru').format(m.createdAt);
      grouped.putIfAbsent(day, () => []).add(m.mood.toDouble());
    }

    List<String> daysOrder = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    List<Map<String, dynamic>> weeklyData = [];

    for (var day in daysOrder) {
      double avg = 0;
      if (grouped.containsKey(day)) {
        avg = grouped[day]!.reduce((a, b) => a + b) / grouped[day]!.length;
      }
      weeklyData.add({'day': day, 'avg': avg});
    }

    setState(() => _weeklyMoods = weeklyData);
  }

  Color _getMoodColor(double mood) {
    if (mood >= 4.5) return Colors.green;
    if (mood >= 3.5) return Colors.lightGreen;
    if (mood >= 2.5) return Colors.amber;
    if (mood >= 1.5) return Colors.orange;
    return Colors.red;
  }

  String _getMoodEmoji(dynamic mood) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Статистика')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final stats = _stats!;
    final distribution = stats['distribution'] as List;
    final topTags = stats['topTags'] as List;

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.notes_rounded,
                              color: Colors.blue, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '${stats['total']}',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Всего записей',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.sentiment_satisfied_alt,
                              color: Colors.green, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '${stats['avgMood'].toStringAsFixed(1)}',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Среднее',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Настроение за неделю',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5,
                  minY: 0,
                  barGroups: _weeklyMoods.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['avg'],
                          color: _getMoodColor(entry.value['avg']),
                          width: 24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _weeklyMoods.length) {
                            return Text(
                              _weeklyMoods[value.toInt()]['day'],
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final emojis = ['', '😭', '😟', '😐', '😊', '😍'];
                          return Text(
                            emojis[value.toInt()],
                            style: const TextStyle(fontSize: 16),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            if (distribution.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Распределение настроений',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...distribution.map((item) {
                int count = item['count'] as int;
                int total = stats['total'] as int;
                double percent = total > 0 ? count / total : 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        _getMoodEmoji(item['mood']),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 24,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              _getMoodColor(
                                  (item['mood'] as int).toDouble()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$count',
                        style:
                        const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (topTags.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Топ тегов',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topTags.map((tag) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      child: Text(
                        '${tag.value}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    label: Text(tag.key),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}