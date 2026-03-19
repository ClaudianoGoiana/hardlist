import 'dart:convert';
import 'package:flutter/material.dart';
import '../dados/banco_local.dart';

class ReceivedListsScreen extends StatefulWidget {
  const ReceivedListsScreen({super.key});

  @override
  State<ReceivedListsScreen> createState() => _ReceivedListsScreenState();
}

class _ReceivedListsScreenState extends State<ReceivedListsScreen> {
  late Future<List<Map<String, dynamic>>> _listasRecebidasFuture;

  @override
  void initState() {
    super.initState();
    _carregarListasCompartilhadas();
  }

  void _carregarListasCompartilhadas() {
    setState(() {
      _listasRecebidasFuture = BancoLocal.listarListasRecebidasLocal();
    });
  }

  Future<void> _refresh() async {
    _carregarListasCompartilhadas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas Recebidas'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _listasRecebidasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final listasRecebidas = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: listasRecebidas.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Nenhuma lista recebida ainda.\nBaixe listas no HardList Cloud para vê-las aqui.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: listasRecebidas.length,
                    itemBuilder: (context, index) {
                      final lista = listasRecebidas[index];
                      final nomeLista = lista['nome']?.toString() ?? 'Lista sem nome';
                      final dataCompartilhamento = lista['data_compartilhamento']?.toString() ?? '';
                      final produtosJson = lista['produtos_json']?.toString() ?? '[]';
                        final criadorNome = (lista['criador_nome']?.toString() ?? '').trim();
                        final donoLabel = criadorNome.isNotEmpty
                          ? 'Compartilhada por: $criadorNome'
                          : 'Compartilhada por: não informado';

                      // Conta produtos
                      int qtdProdutos = 0;
                      try {
                        final List<dynamic> produtos = jsonDecode(produtosJson);
                        qtdProdutos = produtos.length;
                      } catch (_) {}

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(Icons.download_done, color: Colors.orange),
                          ),
                          title: Text(nomeLista, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '$qtdProdutos produtos • Recebida em ${_formatarData(dataCompartilhamento)}\n$donoLabel',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          trailing: const Icon(Icons.visibility, color: Colors.grey),
                          onTap: () {
                            _mostrarDetalhesLista(context, lista);
                          },
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  String _formatarData(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year;
      return '$d/$m/$y';
    } catch (_) {
      return iso;
    }
  }

  void _mostrarDetalhesLista(BuildContext context, Map<String, dynamic> lista) {
    final nomeLista = lista['nome']?.toString() ?? 'Lista';
    final produtosJson = lista['produtos_json']?.toString() ?? '[]';
    final criadorNome = (lista['criador_nome']?.toString() ?? '').trim();

    List<dynamic> produtos = [];
    if (produtosJson.isNotEmpty) {
      try {
        produtos = jsonDecode(produtosJson);
      } catch (_) {}
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nomeLista),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (criadorNome.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Compartilhada por: $criadorNome',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              Flexible(
                child: produtos.isEmpty
                    ? const Center(child: Text('Nenhum produto nesta lista'))
                    : ListView.builder(
                        itemCount: produtos.length,
                        itemBuilder: (context, index) {
                          final p = produtos[index];
                          final nome = p['nome']?.toString() ?? '';
                          final qtd = p['quantidade']?.toString() ?? '1';
                          final preco = (p['preco'] as num?)?.toDouble() ?? 0.0;
                          final qtdNum = int.tryParse(qtd) ?? 1;
                          final subtotal = preco * qtdNum;

                          return ListTile(
                            title: Text(nome),
                            subtitle: Text('Qtd: $qtd'),
                            trailing: Text(
                              'R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
