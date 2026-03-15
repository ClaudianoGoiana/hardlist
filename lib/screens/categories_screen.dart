// Arquivo: lib/screens/categories_screen.dart
import 'package:flutter/material.dart';
import 'products_screen.dart'; // Importa a nossa tela inteligente de produtos!

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  // A nossa lista oficial de corredores do mercado
  final List<String> _categorias = const [
    'Mercearia', 'Açougue', 'Hortifruti', 'Frios e Laticínios', 
    'Bebidas', 'Limpeza', 'Higiene', 'Padaria', 'Outros'
  ];

  // --- O NOSSO "DICIONÁRIO DE ÍCONES" (MAPA) ---
  final Map<String, IconData> _iconesPorCategoria = const {
    'Mercearia': Icons.shopping_basket,     // Cestinha de compras
    'Açougue': Icons.set_meal,              // Carnes/Peixes
    'Hortifruti': Icons.eco,                // Folha/Natureza
    'Frios e Laticínios': Icons.kitchen,    // Geladeira
    'Bebidas': Icons.local_cafe,            // Copo/Xícara
    'Limpeza': Icons.cleaning_services,     // Vassoura/Limpeza
    'Higiene': Icons.bathtub,               // Banheira/Banho
    'Padaria': Icons.bakery_dining,         // Pão/Croissant
    'Outros': Icons.category,               // Formas geométricas
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      // Construindo uma lista na tela
      body: ListView.builder(
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          
          // 1. O APLICATIVO LÊ EXATAMENTE QUAL CATEGORIA ESTÁ DESENHANDO AGORA
          final String categoriaAtual = _categorias[index]; 

          // 2. BUSCA O ÍCONE NO NOSSO DICIONÁRIO (Se não achar, usa a sacola padrão)
          final IconData iconeDaCategoria = _iconesPorCategoria[categoriaAtual] ?? Icons.shopping_bag;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              // 3. DESENHA O ÍCONE DINÂMICO AQUI!
              leading: Icon(iconeDaCategoria, color: const Color(0xFF1565C0), size: 28),
              
              title: Text(
                categoriaAtual, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                // 4. A MÁGICA DA NAVEGAÇÃO
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductsScreen(categoriaNome: categoriaAtual),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}