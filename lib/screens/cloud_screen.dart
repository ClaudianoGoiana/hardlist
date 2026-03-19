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
  late Future<List<Map<String, dynamic>>> _minhasListasFuture;
  late Future<List<Map<String, dynamic>>> _listasRecebidasFuture;
  String? _usuarioId;
  String _meuNome = 'Você';

  @override
  void initState() {
    super.initState();
    final usuario = Supabase.instance.client.auth.currentUser;
    _usuarioId = usuario?.id;
    _meuNome =
        (usuario?.userMetadata?['name']?.toString().trim().isNotEmpty ?? false)
            ? usuario!.userMetadata!['name'].toString().trim()
            : (usuario?.email?.split('@').first ?? 'Você');
    _minhasListasFuture = BancoLocal.listarListasNaNuvemDoUsuario();
    _listasRecebidasFuture = BancoLocal.buscarListasCompartilhadasNuvem();
  }

  bool _toBool(dynamic valor, {bool padrao = true}) {
    if (valor is bool) return valor;
    if (valor is num) return valor != 0;
    if (valor is String) {
      final v = valor.trim().toLowerCase();
      if (v == 'true' || v == '1') return true;
      if (v == 'false' || v == '0') return false;
    }
    return padrao;
  }

  Future<void> _refresh() async {
    setState(() {
      _minhasListasFuture = BancoLocal.listarListasNaNuvemDoUsuario();
      _listasRecebidasFuture = BancoLocal.buscarListasCompartilhadasNuvem();
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
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait<dynamic>([
          _minhasListasFuture,
          _listasRecebidasFuture,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final minhasListas = (snapshot.data?[0] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final listasRecebidas = (snapshot.data?[1] as List?)?.cast<Map<String, dynamic>>() ?? [];

          if (minhasListas.isEmpty && listasRecebidas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Nenhuma lista na nuvem disponível no momento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              if (minhasListas.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Text(
                    'Listas na nuvem (enviadas por mim)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ...minhasListas.map((lista) => _buildMinhaListaTile(lista)),
              ],
              if (listasRecebidas.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
                  child: Text(
                    'Listas de outros usuários (somente visualização)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ...listasRecebidas.map((lista) => _buildListaCompartilhadaTile(lista)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMinhaListaTile(Map<String, dynamic> lista) {
    final publica = _toBool(lista['publica'], padrao: true);
    return ListTile(
      title: Text(
        lista['nome']?.toString() ?? '',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Enviada por: $_meuNome\nVisibilidade: ${publica ? 'Pública' : 'Privada'}\nCompartilhada em: ${_formatarData(lista['data_compartilhamento'])}',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(value, lista),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'editar', child: Text('Editar')),
          const PopupMenuItem(value: 'remover', child: Text('Remover')),
        ],
      ),
      onTap: () => _verDetalhesLista(context, lista),
    );
  }

  Widget _buildListaCompartilhadaTile(Map<String, dynamic> lista) {
    final criadorNome = (lista['criador_nome']?.toString() ?? '').trim();
    final donoLabel = criadorNome.isNotEmpty ? 'Compartilhada por $criadorNome' : 'Dono nao informado';
    final publica = _toBool(lista['publica'], padrao: true);

    return ListTile(
      title: Text(
        lista['nome']?.toString() ?? '',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '$donoLabel\nVisibilidade: ${publica ? 'Pública' : 'Privada'}\nCompartilhada em: ${_formatarData(lista['data_compartilhamento'])}',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.download, color: Colors.grey),
      onTap: () => _verDetalhesLista(context, lista, permitirDownload: true),
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
    final isPropria = lista['usuario_id'] == _usuarioId;
    if (!isPropria) return;

    switch (action) {
      case 'editar':
        _editarLista(context, lista);
        break;
      case 'remover':
        _removerLista(context, lista);
        break;
    }
  }

  void _verDetalhesLista(BuildContext context, Map<String, dynamic> lista, {bool permitirDownload = false}) {
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
          if (permitirDownload)
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await BancoLocal.fazerDownloadLista(
                    id: lista['id']?.toString() ?? '',
                    listaId: lista['lista_id']?.toString() ?? '',
                    nome: lista['nome']?.toString() ?? 'Lista',
                    usuarioId: lista['usuario_id']?.toString() ?? '',
                    produtosJson: lista['produtos_json']?.toString() ?? '[]',
                    criadorNome: lista['criador_nome']?.toString(),
                  );

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lista baixada para Minhas Listas e Listas Recebidas.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao baixar lista: $e')),
                  );
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Baixar'),
            ),
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
    bool publica = _toBool(lista['publica'], padrao: true);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar Lista'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Nome da lista'),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: publica,
                title: const Text('Lista pública'),
                subtitle: Text(publica
                    ? 'Outros usuários podem visualizar e baixar.'
                    : 'Somente você pode visualizar.'),
                onChanged: (valor) {
                  setStateDialog(() {
                    publica = valor;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final novoNome = controller.text.trim();
                if (novoNome.isNotEmpty) {
                  await BancoLocal.atualizarListaNaCloud(
                    id: lista['id']?.toString() ?? '',
                    nome: novoNome,
                    produtosJson: lista['produtos_json']?.toString() ?? '[]',
                    publica: publica,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _refresh();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
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
              await BancoLocal.removerListaDaNuvem(lista['id']?.toString() ?? '');
              if (!context.mounted) return;
              Navigator.pop(context);
              _refresh();
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

}