// Arquivo: lib/screens/lists_screen.dart
import 'package:flutter/material.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulando os dados das suas listas baseados na Imagem 4
    final List<Map<String, dynamic>> minhasListas = [
      {'nome': 'Maris', 'comprados': 0, 'total': 0, 'icone': Icons.playlist_add_check},
      {'nome': 'Feira Do Mês', 'comprados': 6, 'total': 45, 'icone': Icons.format_list_bulleted},
      {'nome': 'Minha lista', 'comprados': 29, 'total': 29, 'icone': Icons.format_list_bulleted},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas'),
        backgroundColor: const Color(0xFF1565C0), // Nosso Azul principal
        actions: [
          // Ícone de ordenar/filtrar no canto direito
          IconButton(icon: const Icon(Icons.sort), onPressed: () {}),
        ],
      ),
      body: ListView.separated(
        itemCount: minhasListas.length,
        // Linha divisória fina e cinza
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final lista = minhasListas[index];
          
          return ListTile(
            // Ícone da esquerda
            leading: Icon(lista['icone'], color: Colors.grey.shade600),
            
            // Nome da lista
            title: Text(lista['nome'], style: const TextStyle(fontSize: 16)),
            
            // Quantidade (comprados / total)
            subtitle: Text(
              '(${lista['comprados']}/${lista['total']})', 
              style: const TextStyle(color: Colors.grey)
            ),
            
            // Setinha indicando para ir em frente
            trailing: const Icon(Icons.arrow_forward, color: Colors.grey),
            
            onTap: () {
              // No futuro, isso vai abrir a tela de Produtos específica desta lista
              print("Abrir a lista: ${lista['nome']}");
            },
          );
        },
      ),
      // Botão flutuante para criar nova lista
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1976D2), // Azul vibrante
        onPressed: () {
          print("Criar nova lista clicado");
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}