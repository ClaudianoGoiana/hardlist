import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HardListApp());
}

// Classe principal do aplicativo
class HardListApp extends StatelessWidget {
  const HardListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HardList',
      debugShowCheckedModeBanner: false, // Remove a faixa de 'debug'
      theme: ThemeData(
        // Definimos um azul escuro principal para o app
        primaryColor: const Color(0xFF1565C0), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0), // Cor da barra superior
          foregroundColor: Colors.white, // Cor do texto e ícones na barra
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF1976D2), // Cor do botão flutuante (+)
        ),
      ),
      // Define a tela inicial que será aberta
      home: const HomeScreen(), 
    );
  }
}