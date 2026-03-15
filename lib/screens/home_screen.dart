// Arquivo: lib/screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_product_screen.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  final String listaId;   // RECEBE O ID DA LISTA
  final String listaNome; // RECEBE O NOME DA LISTA

  const HomeScreen({super.key, required this.listaId, required this.listaNome});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      // MÁGICA 1: O Filtro .eq('lista_id', listaId) só traz os produtos DESTA lista!
      stream: Supabase.instance.client.from('produtos').stream(primaryKey: ['id']).eq('lista_id', listaId),
      builder: (context, snapshot) {
        
        double valorTotalLista = 0.0;
        double valorNoCarrinho = 0.0;
        List<Map<String, dynamic>> produtos = [];

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          produtos = snapshot.data!;
          for (var produto in produtos) {
            double preco = (produto['preco'] as num).toDouble();
            int qtd = int.tryParse(produto['quantidade'].toString()) ?? 1;
            bool comprado = produto['comprado'] ?? false;
            
            double totalDoItem = preco * qtd;
            valorTotalLista += totalDoItem;
            if (comprado) valorNoCarrinho += totalDoItem;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(listaNome), // MOSTRA O NOME DA LISTA LÁ EM CIMA
            actions: [
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          drawer: const AppDrawer(),
          
          body: produtos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.turn_right, size: 80, color: Colors.grey.shade400),
                      Text('Sua lista "$listaNome"\nestá vazia.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, color: Colors.grey)),
                    ],
                  ),
                )
              : _construirListaAgrupada(produtos, context),

          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF1565C0),
            onPressed: () {
              // MÁGICA 2: Passa o ID da lista para a tela de Adicionar Produto
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductScreen(listaId: listaId)));
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),

          bottomNavigationBar: _construirBarraInferior(context, valorTotalLista, valorNoCarrinho),
        );
      },
    );
  }

  // ... (Daqui para baixo é exatamente igual ao que já tínhamos) ...

  Widget _construirListaAgrupada(List<Map<String, dynamic>> produtos, BuildContext context) {
    Map<String, List<Map<String, dynamic>>> produtosAgrupados = {};
    for (var produto in produtos) {
      String categoria = produto['categoria'] ?? 'Outros';
      if (!produtosAgrupados.containsKey(categoria)) produtosAgrupados[categoria] = [];
      produtosAgrupados[categoria]!.add(produto);
    }
    final categoriasNomes = produtosAgrupados.keys.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: categoriasNomes.length,
      itemBuilder: (context, index) {
        String categoria = categoriasNomes[index];
        List<Map<String, dynamic>> itensDaCategoria = produtosAgrupados[categoria]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, color: isDark ? Colors.grey.shade800 : Colors.blue.shade50, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(categoria, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
            ),
            ...itensDaCategoria.map((produto) {
              final String? caminhoFoto = produto['caminho_foto_local'];
              final bool comprado = produto['comprado'] ?? false;
              final double preco = (produto['preco'] as num).toDouble();
              final int qtd = int.tryParse(produto['quantidade'].toString()) ?? 1;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300, width: 1)),
                child: ListTile(
                  onTap: () => _mostrarMenuDeOpcoes(context, produto),
                  leading: Checkbox(value: comprado, activeColor: const Color(0xFF1565C0), onChanged: (bool? valor) async { await Supabase.instance.client.from('produtos').update({'comprado': valor}).eq('id', produto['id']); }),
                  title: Text(produto['nome'], style: TextStyle(fontWeight: FontWeight.bold, decoration: comprado ? TextDecoration.lineThrough : null, color: comprado ? Colors.grey : null)),
                  subtitle: Text('${produto['quantidade']} un.'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('R\$ ${(preco * qtd).toStringAsFixed(2).replaceAll('.', ',')}', style: TextStyle(color: comprado ? Colors.grey : const Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      if (caminhoFoto != null) ClipRRect(borderRadius: BorderRadius.circular(8), child: kIsWeb ? Image.network(caminhoFoto, width: 45, height: 45, fit: BoxFit.cover) : Image.file(File(caminhoFoto), width: 45, height: 45, fit: BoxFit.cover))
                      else const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _mostrarMenuDeOpcoes(BuildContext context, Map<String, dynamic> produto) {
    showModalBottomSheet(context: context, builder: (context) {
      return SafeArea(child: Wrap(children: [
        ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text('Editar Produto'), onTap: () { Navigator.pop(context); _mostrarTelaDeEdicao(context, produto); }),
        ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('Excluir Produto'), onTap: () async { Navigator.pop(context); await Supabase.instance.client.from('produtos').delete().eq('id', produto['id']); }),
      ]));
    });
  }

  void _mostrarTelaDeEdicao(BuildContext context, Map<String, dynamic> produto) {
    final nomeController = TextEditingController(text: produto['nome']);
    final qtdController = TextEditingController(text: produto['quantidade'].toString());
    final precoController = TextEditingController(text: produto['preco'].toString());

    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Editar Produto'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Produto')),
          Row(children: [
            Expanded(child: TextField(controller: qtdController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantidade'))),
            const SizedBox(width: 16),
            Expanded(child: TextField(controller: precoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Preço (R\$)'))),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              String precoTexto = precoController.text.replaceAll(',', '.');
              double precoFinal = double.tryParse(precoTexto) ?? 0.0;
              await Supabase.instance.client.from('produtos').update({'nome': nomeController.text, 'quantidade': qtdController.text, 'preco': precoFinal}).eq('id', produto['id']);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    });
  }

  Widget _construirBarraInferior(BuildContext context, double valorTotalLista, double valorNoCarrinho) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
      child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total da Lista', style: TextStyle(color: Colors.grey, fontSize: 13)),
          Text('R\$ ${valorTotalLista.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(12)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('No Carrinho', style: TextStyle(color: Colors.white70, fontSize: 13)),
            Text('R\$ ${valorNoCarrinho.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          ]),
        ),
      ])),
    );
  }
}