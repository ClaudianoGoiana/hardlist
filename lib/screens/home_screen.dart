// Arquivo: lib/screens/home_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../dados/banco_local.dart'; // O nosso cofre local!
import 'add_product_screen.dart';
import 'history_screen.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  final String listaId;
  final String listaNome;

  const HomeScreen({super.key, required this.listaId, required this.listaNome});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _formatarPrecoComoMoeda(String textoDigitado) {
    final somenteNumeros = textoDigitado.replaceAll(RegExp(r'[^0-9]'), '');
    final baseNumerica = somenteNumeros.isEmpty ? '0' : somenteNumeros;
    final valor = (double.tryParse(baseNumerica) ?? 0) / 100;
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  List<Map<String, dynamic>> _produtos = [];
  bool _carregando = true;
  String _nomeListaAtual = '';

  @override
  void initState() {
    super.initState();
    _carregarProdutos(); // Carrega os itens do cofre assim que a tela abre
  }

  // --- FUNÇÃO PARA BUSCAR OS PRODUTOS DESTA LISTA NO CELULAR ---
  Future<void> _carregarProdutos() async {
    try {
      final db = await BancoLocal.bancoDeDados;
      final lista = await db.query(
        'listas',
        where: 'id = ?',
        whereArgs: [widget.listaId],
        limit: 1,
      );
      // Busca apenas os produtos que têm a etiqueta (lista_id) desta lista!
      final dados = await db.query(
        'produtos',
        where: 'lista_id = ?',
        whereArgs: [widget.listaId],
      );

      setState(() {
        _nomeListaAtual =
            (lista.isNotEmpty ? lista.first['nome']?.toString() : null) ??
            widget.listaNome;
        _produtos = dados;
        _carregando = false;
      });
    } catch (erro) {
      debugPrint('Erro ao carregar produtos: $erro');
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculando os totais antes de desenhar a tela
    double valorTotalLista = 0.0;
    double valorNoCarrinho = 0.0;

    for (var produto in _produtos) {
      double preco = (produto['preco'] as num).toDouble();
      int qtd = int.tryParse(produto['quantidade'].toString()) ?? 1;

      // O SQLite usa 1 para Verdadeiro e 0 para Falso!
      bool comprado = produto['comprado'] == 1;

      double totalDoItem = preco * qtd;
      valorTotalLista += totalDoItem;
      if (comprado) valorNoCarrinho += totalDoItem;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _nomeListaAtual.isEmpty ? widget.listaNome : _nomeListaAtual,
        ),
        actions: [
          // Botão para compartilhar no cloud (só se estiver logado)
          if (Supabase.instance.client.auth.currentUser != null)
            IconButton(
              icon: const Icon(Icons.cloud_upload),
              tooltip: 'Compartilhar no Cloud',
              onPressed: () => _compartilharLista(context),
            ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      drawer: const AppDrawer(),

      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _produtos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.turn_right, size: 80, color: Colors.grey.shade400),
                  Text(
                    'Sua lista "${_nomeListaAtual.isEmpty ? widget.listaNome : _nomeListaAtual}"\nestá vazia.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _construirListaAgrupada(_produtos, context),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1565C0),
        onPressed: () async {
          // MÁGICA DE NAVEGAÇÃO: Ele vai para a tela de adicionar e FICA ESPERANDO (await) você voltar.
          // Quando você voltar, ele manda carregar os produtos de novo para a lista atualizar na hora!
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(listaId: widget.listaId),
            ),
          );
          _carregarProdutos();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: _construirBarraInferior(
        context,
        valorTotalLista,
        valorNoCarrinho,
      ),
    );
  }

  Widget _construirListaAgrupada(
    List<Map<String, dynamic>> produtos,
    BuildContext context,
  ) {
    Map<String, List<Map<String, dynamic>>> produtosAgrupados = {};
    for (var produto in produtos) {
      String categoria = produto['categoria'] ?? 'Outros';
      if (!produtosAgrupados.containsKey(categoria))
        produtosAgrupados[categoria] = [];
      produtosAgrupados[categoria]!.add(produto);
    }

    final categoriasNomes = produtosAgrupados.keys.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: categoriasNomes.length,
      itemBuilder: (context, index) {
        String categoria = categoriasNomes[index];
        List<Map<String, dynamic>> itensDaCategoria =
            produtosAgrupados[categoria]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: isDark ? Colors.grey.shade800 : Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                categoria,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
            ...itensDaCategoria.map((produto) {
              final String? caminhoFoto = produto['caminho_foto_local'];
              final bool comprado = produto['comprado'] == 1; // Tradução SQLite
              final double preco = (produto['preco'] as num).toDouble();
              final int qtd =
                  int.tryParse(produto['quantidade'].toString()) ?? 1;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: ListTile(
                  onTap: () => _mostrarMenuDeOpcoes(context, produto),

                  // CHECKBOX DO CARRINHO
                  leading: Checkbox(
                    value: comprado,
                    activeColor: const Color(0xFF1565C0),
                    onChanged: (bool? valor) async {
                      final db = await BancoLocal.bancoDeDados;
                      // Transforma true/false em 1/0 para o banco
                      await db.update(
                        'produtos',
                        {'comprado': valor == true ? 1 : 0},
                        where: 'id = ?',
                        whereArgs: [produto['id']],
                      );
                      _carregarProdutos(); // Atualiza a tela
                    },
                  ),

                  title: Text(
                    produto['nome'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: comprado ? TextDecoration.lineThrough : null,
                      color: comprado ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text('${produto['quantidade']} un.'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'R\$ ${(preco * qtd).toStringAsFixed(2).replaceAll('.', ',')}',
                        style: TextStyle(
                          color: comprado
                              ? Colors.grey
                              : const Color(0xFF1565C0),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mostra imagem de asset, arquivo local ou URL, com fallback.
                      if (caminhoFoto != null &&
                          caminhoFoto.startsWith('assets/'))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            caminhoFoto,
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.shopping_bag,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      else if (caminhoFoto != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.network(
                                  caminhoFoto,
                                  width: 45,
                                  height: 45,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.shopping_bag,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                )
                              : Image.file(
                                  File(caminhoFoto),
                                  width: 45,
                                  height: 45,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.shopping_bag,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                        )
                      else
                        const Icon(
                          Icons.shopping_bag,
                          size: 40,
                          color: Colors.grey,
                        ),
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

  void _mostrarMenuDeOpcoes(
    BuildContext context,
    Map<String, dynamic> produto,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Editar Produto'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarTelaDeEdicao(context, produto);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Excluir Produto'),
                onTap: () async {
                  Navigator.pop(context);
                  final db = await BancoLocal.bancoDeDados;
                  await db.delete(
                    'produtos',
                    where: 'id = ?',
                    whereArgs: [produto['id']],
                  );
                  _carregarProdutos(); // Atualiza a tela
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarTelaDeEdicao(
    BuildContext context,
    Map<String, dynamic> produto,
  ) {
    final nomeController = TextEditingController(text: produto['nome']);
    final qtdController = TextEditingController(
      text: produto['quantidade'].toString(),
    );
    final precoAtual = (produto['preco'] as num?)?.toDouble() ?? 0.0;
    final precoController = TextEditingController(
      text: precoAtual.toStringAsFixed(2).replaceAll('.', ','),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Produto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: precoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Preço (R\$)',
                      ),
                      onChanged: (texto) {
                        final textoFormatado = _formatarPrecoComoMoeda(texto);
                        if (textoFormatado == precoController.text) return;
                        precoController.value = TextEditingValue(
                          text: textoFormatado,
                          selection: TextSelection.collapsed(
                            offset: textoFormatado.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
                String precoTexto = precoController.text.replaceAll(',', '.');
                double precoFinal = double.tryParse(precoTexto) ?? 0.0;

                final db = await BancoLocal.bancoDeDados;
                await db.update(
                  'produtos',
                  {
                    'nome': nomeController.text,
                    'quantidade': qtdController.text,
                    'preco': precoFinal,
                  },
                  where: 'id = ?',
                  whereArgs: [produto['id']],
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  _carregarProdutos(); // Atualiza a tela
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // Função para confirmar a compra
  Future<void> _confirmarCompra(
    BuildContext context,
    double valorCompra,
  ) async {
    // Se não há itens no carrinho, não faz nada
    final itensNoCarrinho = _produtos.where((p) => p['comprado'] == 1).toList();
    if (itensNoCarrinho.isEmpty) return;

    // Salva o histórico da compra
    final id = const Uuid().v4();
    final dataAgora = DateTime.now().toIso8601String();
    final produtosJson = jsonEncode(itensNoCarrinho);

    await BancoLocal.adicionarHistorico(
      id: id,
      listaId: widget.listaId,
      nome: widget.listaNome,
      data: dataAgora,
      valor: valorCompra,
      produtosJson: produtosJson,
    );

    // Limpa o carrinho (marca itens como não comprados)
    final db = await BancoLocal.bancoDeDados;
    for (var item in itensNoCarrinho) {
      await db.update(
        'produtos',
        {'comprado': 0},
        where: 'id = ?',
        whereArgs: [item['id']],
      );
    }

    await _carregarProdutos();

    // Navega para o histórico e, ao voltar, mostra um aviso
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Compra de R\$ ${valorCompra.toStringAsFixed(2).replaceAll('.', ',')} confirmada!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // Função para compartilhar lista no cloud
  Future<void> _compartilharLista(BuildContext context) async {
    final usuario = Supabase.instance.client.auth.currentUser;
    if (usuario == null) return;

    final id = const Uuid().v4();
    final produtosJson = jsonEncode(_produtos);

    // Verifica se a lista já existe na nuvem para este usuário.
    final listasNuvem = await BancoLocal.listarListasNaNuvemDoUsuario();
    final listaJaCompartilhada = listasNuvem.any(
      (lista) =>
          lista['id'] == widget.listaId || lista['lista_id'] == widget.listaId,
    );

    if (listaJaCompartilhada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta lista já está na nuvem')),
      );
      return;
    }

    try {
      // Salva localmente
      await BancoLocal.compartilharLista(
        id: id,
        listaId: widget.listaId,
        nome: widget.listaNome,
        usuarioId: usuario.id,
        produtosJson: produtosJson,
      );

      if (!context.mounted) return;

      final bool enviarParaNuvem =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Enviar para nuvem?'),
              content: const Text(
                'A lista já foi salva localmente. Deseja enviar para a nuvem também?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Não'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sim'),
                ),
              ],
            ),
          ) ??
          false;

      if (!enviarParaNuvem) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lista salva localmente.')),
        );
        return;
      }

      if (!context.mounted) return;
      final bool? publicarComoPublica = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Visibilidade da lista'),
          content: const Text(
            'Deseja publicar esta lista como pública (visível para outros usuários) ou privada (somente você)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Privada'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Pública'),
            ),
          ],
        ),
      );

      if (publicarComoPublica == null) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enviando para nuvem...')));

      // Sincroniza com Supabase para outros usuários verem
      await BancoLocal.compartilharListaNaCloud(
        id: id,
        listaId: widget.listaId,
        nome: widget.listaNome,
        usuarioId: usuario.id,
        produtosJson: produtosJson,
        publica: publicarComoPublica,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista compartilhada com sucesso!')),
      );
    } catch (e) {
      // Se falhar no envio para a nuvem, remove o registro local dessa tentativa
      // para permitir novo envio sem bloquear por "já compartilhada".
      try {
        await BancoLocal.removerListaCloud(id, usuario.id);
      } catch (_) {}

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao compartilhar: $e')));
    }
  }

  Widget _construirBarraInferior(
    BuildContext context,
    double valorTotalLista,
    double valorNoCarrinho,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total da Lista',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  'R\$ ${valorTotalLista.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No Carrinho',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    'R\$ ${valorNoCarrinho.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Botão de confirmar compra (só aparece se há itens no carrinho)
            if (valorNoCarrinho > 0)
              ElevatedButton.icon(
                onPressed: () => _confirmarCompra(context, valorNoCarrinho),
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirmar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
