// Arquivo: lib/screens/received_lists_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dados/banco_local.dart';

class ReceivedListsScreen extends StatefulWidget {
  const ReceivedListsScreen({super.key});

  @override
  State<ReceivedListsScreen> createState() => _ReceivedListsScreenState();
}

class _ReceivedListsScreenState extends State<ReceivedListsScreen> {
  late Future<List<Map<String, dynamic>>> _listasCompartilhadasFuture;

  @override
  void initState() {
    super.initState();
    _carregarListasCompartilhadas();
  }

  void _carregarListasCompartilhadas() {
    setState(() {
      _listasCompartilhadasFuture = BancoLocal.buscarListasCompartilhadasNuvem();
    });
  }

  Future<void> _refresh() async {
    _carregarListasCompartilhadas();
  }

  Future<void> _fazerDownload(Map<String, dynamic> lista) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Baixando lista...')),
      );

      await BancoLocal.fazerDownloadLista(
        id: lista['id'],
        listaId: lista['lista_id'],
        nome: lista['nome'],
        usuarioId: lista['usuario_id'],
        produtosJson: lista['produtos_json'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista importada com sucesso!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao importar: $e')),
      );
    }
  }

  void _removerListaDaNuvem(String id) async {
    try {
      await BancoLocal.removerListaDaNuvem(id);
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista removida'), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas Compartilhadas'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _listasCompartilhadasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final listasCompartilhadas = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: listasCompartilhadas.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Nenhuma lista compartilhada disponível.\nOutros usuários compartilham listas aqui no HardList Cloud!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: listasCompartilhadas.length,
                    itemBuilder: (context, index) {
                      final lista = listasCompartilhadas[index];
                      final nomeLista = lista['nome']?.toString() ?? 'Lista sem nome';
                      final dataCompartilhamento = lista['data_compartilhamento']?.toString() ?? '';
                      final produtosJson = lista['produtos_json']?.toString() ?? '[]';
                      final criadoPorId = lista['criador_id']?.toString() ?? '';

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
                            child: const Icon(Icons.cloud_download, color: Colors.orange),
                          ),
                          title: Text(nomeLista, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '$qtdProdutos produtos • ${_formatarData(dataCompartilhamento)}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Text('Importar'),
                                onTap: () {
                                  _fazerDownload(lista);
                                },
                              ),
                              PopupMenuItem(
                                child: const Text('Visualizar'),
                                onTap: () {
                                  _mostrarDetalhesLista(context, lista);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            // Abre a lista em modo visualização
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
