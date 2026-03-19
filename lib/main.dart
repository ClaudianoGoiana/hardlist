import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'screens/list_screen.dart'; // Verifique se o caminho da pasta é Screen ou screens

// Declare o themeNotifier globalmente
final themeNotifier = ThemeNotifier();

const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
    throw StateError(
      'Variaveis nao configuradas. Use --dart-define=SUPABASE_URL=... '
      'e --dart-define=SUPABASE_ANON_KEY=... ao executar o app.',
    );
  }

  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);

  runApp(
    ChangeNotifierProvider(create: (_) => themeNotifier, child: const MyApp()),
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
