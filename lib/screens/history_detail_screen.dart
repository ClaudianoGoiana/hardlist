// Arquivo: lib/screens/history_detail_screen.dart
import 'package:flutter/material.dart';

class HistoryDetailScreen extends StatelessWidget {
  // Criamos "gavetas" para guardar os dados que virão da tela anterior
  final String nomeDaLista;
  final String dataDaLista;
  final String valorDaLista;

  // Isso é o construtor: ele obriga (required) a tela anterior a mandar esses dados
  const HistoryDetailScreen({
    super.key,
    required this.nomeDaLista,
    required this.dataDaLista,
    required this.valorDaLista,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Compra'),
        backgroundColor: const Color(0xFF1565C0), // Nosso azul padrão
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Um ícone de recibo gigante para ilustrar
            const Icon(Icons.receipt_long, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            
            // Aqui nós usamos os dados que a tela anterior mandou!
            Text(
              nomeDaLista, 
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            Text(
              'Realizada em: $dataDaLista', 
              style: const TextStyle(fontSize: 18, color: Colors.grey)
            ),
            const SizedBox(height: 30),
            
            // O valor em destaque
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFBBDEFB), // Fundo azul claro
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Total: $valorDaLista', 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))
              ),
            ),
          ],
        ),
      ),
    );
  }
}