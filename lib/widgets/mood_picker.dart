import 'package:flutter/material.dart';

class MoodPicker extends StatelessWidget {
  final int selectedMood;
  final Function(int) onMoodSelected;

  const MoodPicker({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const List<Map<String, dynamic>> moods = [
    {'emoji': '😭', 'label': 'Ужасно', 'color': Colors.red},
    {'emoji': '😟', 'label': 'Плохо', 'color': Colors.orange},
    {'emoji': '😐', 'label': 'Норм', 'color': Colors.amber},
    {'emoji': '😊', 'label': 'Хорошо', 'color': Colors.lightGreen},
    {'emoji': '😍', 'label': 'Отлично', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(moods.length, (index) {
        final isSelected = selectedMood == index + 1;
        return GestureDetector(
          onTap: () => onMoodSelected(index + 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (moods[index]['color'] as Color).withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (moods[index]['color'] as Color)
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  moods[index]['emoji'] as String,
                  style: TextStyle(fontSize: isSelected ? 40 : 32),
                ),
                const SizedBox(height: 4),
                Text(
                  moods[index]['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? (moods[index]['color'] as Color)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}