import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'database/database_helper.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  final dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MoodyApp(dbHelper: dbHelper),
    ),
  );
}