// Arquivo: lib/screens/cloud_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dados/banco_local.dart';

class CloudScreen extends StatefulWidget {
  const CloudScreen({super.key});

  @override
  State<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  late Future<List<Map<String, dynamic>>> _listasCloudFuture;
  String? _usuarioId;

  @override
  void initState() {
    super.initState();
    _usuarioId = Supabase.instance.client.auth.currentUser?.id;
    _listasCloudFuture = BancoLocal.listarListasCloud();
  }

  Future<void> _refresh() async {
    setState(() {
      _listasCloudFuture = BancoLocal.listarListasCloud();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HardList Cloud'),
        backgroundColor: const Color(0xFF1565C0),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _listasCloudFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final listas = snapshot.data ?? [];
          if (listas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Nenhuma lista compartilhada ainda. Compartilhe suas listas para que outros usuários possam vê-las.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: listas.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
            itemBuilder: (context, index) {
              final lista = listas[index];
              final isPropria = lista['usuario_id'] == _usuarioId;

              return ListTile(
                title: Text(
                  lista['nome']?.toString() ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Compartilhada em: ${_formatarData(lista['data_compartilhamento'])}',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: isPropria ? PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, lista),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),
                    const PopupMenuItem(value: 'remover', child: Text('Remover')),
                  ],
                ) : null,
                onTap: () => _verDetalhesLista(context, lista),
              );
            },
          );
        },
      ),
    );
  }

  String _formatarData(String? dataIso) {
    if (dataIso == null) return '';
    try {
      final data = DateTime.parse(dataIso);
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    } catch (e) {
      return dataIso;
    }
  }

  void _handleMenuAction(String action, Map<String, dynamic> lista) {
    switch (action) {
      case 'editar':
        _editarLista(context, lista);
        break;
      case 'remover':
        _removerLista(context, lista);
        break;
    }
  }

  void _verDetalhesLista(BuildContext context, Map<String, dynamic> lista) {
    final produtosJson = lista['produtos_json']?.toString() ?? '[]';
    List<dynamic> produtos = [];
    try {
      produtos = jsonDecode(produtosJson);
    } catch (e) {
      // Se não conseguir decodificar, deixa vazio
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lista['nome']?.toString() ?? ''),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index] as Map<String, dynamic>;
              return ListTile(
                title: Text(produto['nome']?.toString() ?? ''),
                subtitle: Text('Qtd: ${produto['quantidade']}, Preço: R\$ ${(produto['preco'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
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

  void _editarLista(BuildContext context, Map<String, dynamic> lista) {
    final controller = TextEditingController(text: lista['nome']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Lista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome da lista'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final novoNome = controller.text.trim();
              if (novoNome.isNotEmpty && _usuarioId != null) {
                await BancoLocal.atualizarListaCloud(
                  lista['id'],
                  novoNome,
                  lista['produtos_json'],
                  _usuarioId!,
                );
                Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _removerLista(BuildContext context, Map<String, dynamic> lista) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Lista'),
        content: const Text('Tem certeza que deseja remover esta lista do cloud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (_usuarioId != null) {
                await BancoLocal.removerListaCloud(lista['id'], _usuarioId!);
                Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}