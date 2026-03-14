// Arquivo: lib/screens/about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o HardList'),
        backgroundColor: const Color(0xFF1565C0), // Nosso Azul principal
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone ou Logo do App
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_cart_checkout, // Ícone provisório do app
                  size: 80,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 24),
              
              // Nome do App
              const Text(
                'HardList',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              // Versão
              Text(
                'Versão 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              
              // Descrição curta
              const Text(
                'O seu gerenciador definitivo de listas de compras. Controle seus gastos, organize seus produtos e nunca mais esqueça nada no supermercado.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              const Divider(),
              const SizedBox(height: 16),
              
              // Créditos
              const Text(
                'Desenvolvido por',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              const Text(
                'Claudiano Goiana - 2026',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}