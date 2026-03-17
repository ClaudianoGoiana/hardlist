// Arquivo: lib/screens/products_screen.dart
import 'package:flutter/material.dart';
import '../dados/catalogo_local.dart';

class ProductsScreen extends StatefulWidget {
  final String? categoriaNome;

  const ProductsScreen({super.key, this.categoriaNome});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _textoBusca = '';
  late String _categoriaSelecionada;

  final List<String> _categorias = [
    'Todos',
    'Açougue',
    'Bebidas',
    'Frios e Laticínios',
    'Higiene',
    'Hortifruti',
    'Limpeza',
    'Mercearia',
    'Outros',
    'Padaria',
  ];

  @override
  void initState() {
    super.initState();
    _categoriaSelecionada = widget.categoriaNome ?? 'Todos';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filtra o catálogo local com base na busca e categoria
    final produtosFiltrados = CatalogoLocal.produtosPadrao.where((produto) {
      final nome = produto['nome']!.toLowerCase();
      final categoria = produto['categoria'] ?? 'Outros';
      final passouBusca = _textoBusca.isEmpty || nome.contains(_textoBusca);
      final passouCategoria =
          _categoriaSelecionada == 'Todos' || categoria == _categoriaSelecionada;
      return passouBusca && passouCategoria;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      body: Column(
        children: [
          // --- ÁREA DE BUSCA E FILTRO ---
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: isDark ? Colors.grey.shade900 : Colors.white,
            child: Column(
              children: [
                // 1. CAMPO DE BUSCA
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar produto...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (valor) {
                    setState(() => _textoBusca = valor.toLowerCase());
                  },
                ),
                const SizedBox(height: 12),

                // 2. DROPDOWN DE CATEGORIA COM SETA
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _categoriaSelecionada,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1565C0)),
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                      items: _categorias.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (novaCategoria) {
                        if (novaCategoria != null) {
                          setState(() => _categoriaSelecionada = novaCategoria);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- LISTA DE PRODUTOS DO CATÁLOGO ---
          Expanded(
            child: produtosFiltrados.isEmpty
                ? const Center(child: Text('Nenhum produto encontrado.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: produtosFiltrados.length,
                    itemBuilder: (context, index) {
                      final produto = produtosFiltrados[index];
                      final foto =
                          produto['foto'] ?? CatalogoLocal.caminhoFotoPadrao(produto['nome'] ?? '');

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: foto != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    foto,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                                  ),
                                )
                              : const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                          title: Text(
                            produto['nome']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Text(
                            produto['categoria'] ?? '',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}