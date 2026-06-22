import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import '../database/database_helper.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const SettingsScreen({super.key, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Тёмная тема'),
            subtitle: const Text('Включить ночной режим'),
            secondary: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('Экспорт в TXT'),
            subtitle: const Text('Сохранить записи в файл'),
            onTap: () async {
              try {
                final text = await dbHelper.exportToText();
                final dir = Directory.systemTemp;
                final file = File('${dir.path}/moody_export.txt');
                await file.writeAsString(text);
                Clipboard.setData(ClipboardData(text: text));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Экспортировано! Файл: ${file.path}\nСодержимое скопировано в буфер'),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка экспорта: $e')),
                  );
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('О приложении'),
            subtitle: const Text('Moody v1.0.0'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Text('🎭'),
                      SizedBox(width: 8),
                      Text('Moody'),
                    ],
                  ),
                  content: const Text(
                    'Дневник настроения\n\nОтслеживай свои эмоции, анализируй статистику и находи закономерности.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Закрыть'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}