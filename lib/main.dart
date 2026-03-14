// Arquivo: lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importando a Home direto para pular o login nos testes

// 1. O nosso "Rádio Comunicador" Global!
// Ele guarda o aviso se o tema atual é Claro ou Escuro.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const HardListApp());
}

class HardListApp extends StatelessWidget {
  const HardListApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. O Ouvinte! Ele fica escutando o rádio 24 horas por dia.
    return ValueListenableBuilder<ThemeMode>(
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
          home: const HomeScreen(), 
        ); // Fim do MaterialApp
        
      }, // Fim do builder
    ); // Fim do ValueListenableBuilder
  } // Fim do build
} // Fim da classe