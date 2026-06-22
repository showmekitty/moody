import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/database_helper.dart';
import '../models/mood_entry.dart';
import '../widgets/mood_card.dart';

class HomeScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const HomeScreen({super.key, required this.dbHelper});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MoodEntry> _moods = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  Future<void> _loadMoods({String? tag}) async {
    setState(() => _isLoading = true);
    final moods = await widget.dbHelper.getAllMoods(searchTag: tag);
    setState(() {
      _moods = moods;
      _isLoading = false;
    });
  }

  Future<void> _deleteMood(int id) async {
    await widget.dbHelper.deleteMood(id);
    _loadMoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moody 🎭'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => context.pushNamed('stats'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по тегам...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadMoods();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.3),
              ),
              onChanged: (value) {
                setState(() {});
                _loadMoods(tag: value.isNotEmpty ? value : null);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _moods.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('😶', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(
                    'Пока нет записей',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Нажми на кнопку ниже, чтобы\nдобавить первое настроение',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _moods.length,
              itemBuilder: (context, index) {
                return MoodCard(
                  entry: _moods[index],
                  onDelete: () => _deleteMood(_moods[index].id!),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.pushNamed('add');
          _loadMoods();
        },
        icon: const Icon(Icons.add),
        label: const Text('Настроение'),
      ),
    );
  }
}