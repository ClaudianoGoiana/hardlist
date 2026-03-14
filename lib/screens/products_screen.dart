// Arquivo: lib/screens/products_screen.dart
import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulando uma lista de produtos (nossa base de dados temporária)
    final List<String> produtos = [
      'Abacate', 'Abacaxi', 'Abacaxi em calda', 'Abóbora', 'Abobrinha',
      'Absorvente íntimo', 'Açafrão', 'Acém', 'Açúcar', 'Açúcar mascavo',
      'Água', 'Água mineral'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          // Ícone de leitor de código de barras
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () {}), 
        ],
      ),
      body: Column(
        children: [
          // 1. Barra de filtro "Todos"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Todos', style: TextStyle(fontSize: 16)),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          
          // 2. Lista de Produtos (usamos Expanded para preencher o resto da tela)
          Expanded(
            // ListView.separated é ótimo porque já cria uma linha divisória entre os itens
            child: ListView.separated(
              itemCount: produtos.length, // Quantidade de itens
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
              itemBuilder: (context, index) {
                return ListTile(
                  // 'leading' é o que fica à esquerda (a foto)
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    // Pegamos a primeira letra do nome do produto para ser o ícone provisório
                    child: Text(
                      produtos[index][0], 
                      style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)
                    ),
                  ),
                  // 'title' é o nome do produto
                  title: Text(produtos[index], style: const TextStyle(fontSize: 16)),
                  onTap: () {
                    print("Clicou no produto: ${produtos[index]}");
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Botão Flutuante de Adicionar
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1976D2), // Nosso azul vibrante
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}