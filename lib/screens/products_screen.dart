// Arquivo: lib/screens/products_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsScreen extends StatefulWidget {
  final String? categoriaNome; // Agora é opcional!

  const ProductsScreen({super.key, this.categoriaNome});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // --- A MEMÓRIA DA TELA ---
  String _textoBusca = '';
  late String _categoriaSelecionada;

  final List<String> _todasCategorias = [
    'Todos', // A opção mestre!
    'Mercearia', 'Açougue', 'Hortifruti', 'Frios e Laticínios', 
    'Bebidas', 'Limpeza', 'Higiene', 'Padaria', 'Outros'
  ];

  @override
  void initState() {
    super.initState();
    // Se a tela abriu vindo de uma categoria, usa ela. Se não, usa 'Todos'.
    _categoriaSelecionada = widget.categoriaNome ?? 'Todos';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      body: Column(
        children: [
          // --- ÁREA DE BUSCA E FILTRO ---
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
            child: Column(
              children: [
                // 1. A LUPA DE BUSCA
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar produto...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (valor) {
                    setState(() {
                      _textoBusca = valor.toLowerCase(); // Atualiza a memória quando você digita
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // 2. A SETINHA DE CATEGORIAS (DROPDOWN)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _categoriaSelecionada,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1565C0)),
                      items: _todasCategorias.map((String categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria, style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (String? novaCategoria) {
                        if (novaCategoria != null) {
                          setState(() {
                            _categoriaSelecionada = novaCategoria; // Atualiza a memória quando você escolhe
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- A LISTA DE PRODUTOS ---
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // Puxamos TODOS os produtos do banco (sem filtro no Supabase)
              stream: Supabase.instance.client.from('produtos').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum produto encontrado.'));
                }

                // 3. O FILTRO INTELIGENTE LOCAL (Acontece na velocidade da luz)
                List<Map<String, dynamic>> produtosFiltrados = snapshot.data!.where((produto) {
                  final nomeProduto = produto['nome'].toString().toLowerCase();
                  final categoriaProduto = produto['categoria']?.toString() ?? 'Outros';

                  // Verifica se o texto digitado bate com o nome
                  final passouNaBusca = _textoBusca.isEmpty || nomeProduto.contains(_textoBusca);
                  // Verifica se a categoria escolhida bate (ou se é 'Todos')
                  final passouNaCategoria = _categoriaSelecionada == 'Todos' || categoriaProduto == _categoriaSelecionada;

                  return passouNaBusca && passouNaCategoria;
                }).toList();

                if (produtosFiltrados.isEmpty) {
                  return const Center(child: Text('Nenhum produto bate com essa busca.'));
                }

                // 4. DESENHA OS PRODUTOS QUE PASSARAM NO FILTRO
                return ListView.builder(
                  itemCount: produtosFiltrados.length,
                  itemBuilder: (context, index) {
                    final produto = produtosFiltrados[index];
                    final String? caminhoFoto = produto['caminho_foto_local'];
                    final bool comprado = produto['comprado'] ?? false;
                    final double preco = (produto['preco'] as num).toDouble();
                    final int qtd = int.tryParse(produto['quantidade'].toString()) ?? 1;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300, width: 1)),
                      child: ListTile(
                        // MANTIVEMOS O CLIQUE PARA EDITAR/EXCLUIR!
                        onTap: () => _mostrarMenuDeOpcoes(context, produto),
                        leading: Checkbox(
                          value: comprado,
                          activeColor: const Color(0xFF1565C0),
                          onChanged: (bool? valor) async {
                            await Supabase.instance.client.from('produtos').update({'comprado': valor}).eq('id', produto['id']);
                          },
                        ),
                        title: Text(
                          produto['nome'],
                          style: TextStyle(fontWeight: FontWeight.bold, decoration: comprado ? TextDecoration.lineThrough : null, color: comprado ? Colors.grey : null),
                        ),
                        subtitle: Text('${produto['quantidade']} un. • ${produto['categoria']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('R\$ ${(preco * qtd).toStringAsFixed(2).replaceAll('.', ',')}', style: TextStyle(color: comprado ? Colors.grey : const Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 8),
                            if (caminhoFoto != null)
                              ClipRRect(borderRadius: BorderRadius.circular(8), child: kIsWeb ? Image.network(caminhoFoto, width: 45, height: 45, fit: BoxFit.cover) : Image.file(File(caminhoFoto), width: 45, height: 45, fit: BoxFit.cover))
                            else
                              const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- A GAVETA DE OPÇÕES E JANELA DE EDIÇÃO (Iguais as que já tínhamos) ---
  void _mostrarMenuDeOpcoes(BuildContext context, Map<String, dynamic> produto) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text('Editar Produto'), onTap: () { Navigator.pop(context); _mostrarTelaDeEdicao(context, produto); }),
              ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('Excluir Produto'), onTap: () async { Navigator.pop(context); await Supabase.instance.client.from('produtos').delete().eq('id', produto['id']); }),
            ],
          ),
        );
      },
    );
  }

  void _mostrarTelaDeEdicao(BuildContext context, Map<String, dynamic> produto) {
    final nomeController = TextEditingController(text: produto['nome']);
    final qtdController = TextEditingController(text: produto['quantidade'].toString());
    final precoController = TextEditingController(text: produto['preco'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Produto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Produto')),
              Row(children: [
                Expanded(child: TextField(controller: qtdController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantidade'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: precoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Preço (R\$)'))),
              ]),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                String precoTexto = precoController.text.replaceAll(',', '.');
                double precoFinal = double.tryParse(precoTexto) ?? 0.0;
                await Supabase.instance.client.from('produtos').update({'nome': nomeController.text, 'quantidade': qtdController.text, 'preco': precoFinal}).eq('id', produto['id']);
                if (context.mounted) { Navigator.pop(context); }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}