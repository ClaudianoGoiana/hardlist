// Arquivo: lib/screens/categories_screen.dart
import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Nossa lista (banco de dados temporário) com as categorias da Imagem 3
    final List<String> categorias = [
      'Bazar e limpeza',
      'Bebidas',
      'Carnes',
      'Comidas Prontas e Congelados',
      'Frios, Leites e Derivados',
      'Frutas, ovos e verduras',
      'Higiene Pessoal',
      'Importados',
      'Mercearia',
      'Padaria e Sobremesas',
      'Saúde e Beleza',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        // O Flutter adiciona automaticamente o botão de voltar (<-) aqui!
      ),
      body: ListView.separated(
        itemCount: categorias.length, // Dizemos ao Flutter quantos itens existem
        // Desenha uma linha cinza bem fina entre cada categoria
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          return ListTile(
            // 'leading' é o ícone da esquerda. Usamos Icons.menu para imitar as 3 barrinhas
            leading: const Icon(Icons.menu, color: Colors.grey),
            // 'title' é o texto da categoria
            title: Text(categorias[index], style: const TextStyle(fontSize: 16)),
            onTap: () {
              // Ação ao clicar na categoria (no futuro pode abrir os produtos dela)
              print("Clicou na categoria: ${categorias[index]}");
            },
          );
        },
      ),
      // Nosso botão flutuante padrão do HardList
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1976D2), // Mantendo o nosso azul
        onPressed: () {
          print("Botão de adicionar categoria clicado");
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}