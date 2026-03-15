// Arquivo: lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- NOVO: Importamos o Supabase
import 'screens/lists_screen.dart'; 

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// <-- MUDANÇA: O main agora é "Future" e "async" para poder esperar o banco de dados ligar
Future<void> main() async {
  // Isto é obrigatório quando usamos coisas como o Supabase antes do runApp
  WidgetsFlutterBinding.ensureInitialized(); 

  // --- LIGAÇÃO AO SUPABASE ---
  await Supabase.initialize(
    url: 'https://zlfhxcksweffglpjelci.supabase.co', // Exemplo: https://abxyz...supabase.co
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsZmh4Y2tzd2VmZmdscGplbGNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MTEzNjYsImV4cCI6MjA4OTA4NzM2Nn0.7uTTIkA0FwPOv2XIWhXMBynmXEFW3ovFucooL1XuRsU', // Aquele texto gigante
  );

  runApp(const HardListApp());
}

class HardListApp extends StatelessWidget {
  const HardListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
// ... (O resto do código para baixo continua exatamente igual!) ...
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HardList',
          
          // --- TEMA CLARO Padrão ---
          theme: ThemeData(
            primaryColor: const Color(0xFF1565C0),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1565C0),
              foregroundColor: Colors.white, // Cor do texto e ícones da AppBar
            ),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
          ),

          // --- TEMA ESCURO ---
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: const Color(0xFF1565C0),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D47A1), // Um azul ainda mais escuro para o topo
              foregroundColor: Colors.white,
            ),
            // O fundo preto e os textos brancos o Flutter já faz sozinho no ThemeData.dark()
          ),

          // 3. A Mágica: Ele muda de claro para escuro dependendo do que o rádio falar!
          themeMode: currentMode, 

          // MUDAMOS AQUI: Tiramos o LoginScreen() e colocamos o HomeScreen()
          home: const ListsScreen(),
        ); // Fim do MaterialApp
        
      }, // Fim do builder
    ); // Fim do ValueListenableBuilder
  } // Fim do build
} // Fim da classe