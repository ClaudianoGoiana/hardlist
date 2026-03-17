import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'screens/list_screen.dart'; // Verifique se o caminho da pasta é Screen ou screens

// Declare o themeNotifier globalmente
final themeNotifier = ThemeNotifier();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zlfhxcksweffglpjelci.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsZmh4Y2tzd2VmZmdscGplbGNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MTEzNjYsImV4cCI6MjA4OTA4NzM2Nn0.7uTTIkA0FwPOv2XIWhXMBynmXEFW3ovFucooL1XuRsU',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeNotifier,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // O App fica "escutando" o rádio do tema aqui
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HardList',
      theme: themeNotifier.value == ThemeMode.dark
          ? ThemeData.dark(useMaterial3: true) 
          : ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
      home: const ListScreen(),
    );
  }
}