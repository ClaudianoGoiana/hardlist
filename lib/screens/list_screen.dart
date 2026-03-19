import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../dados/banco_local.dart'; 
import 'home_screen.dart';
import '../widgets/app_drawer.dart';

// APAGUEI A CLASSE REPETIDA QUE ESTAVA AQUI EM CIMA!

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Map<String, dynamic>> _listas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _atualizarListasNaTela();
  }

  Future<void> _atualizarListasNaTela() async {
    try {
      final db = await BancoLocal.bancoDeDados;
      final listasDoBanco = await db.query('listas', orderBy: 'nome ASC'); 
      
      if (!mounted) return;
      setState(() {
        _listas = listasDoBanco;
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() { _carregando = false; });
      debugPrint('Erro no banco de dados: $erro');
    }
  }

  @override
  Widget build(BuildContext context) {
    final int quantidadeDeListas = _listas.length;
    final bool limiteAtingido = quantidadeDeListas >= 20;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Listas'),
        elevation: 2,
      ),
      drawer: const AppDrawer(),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // LOGO DO APP
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_cart_checkout,
                          size: 40,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'HardList',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _listas.isEmpty
                      ? const Center(
                          child: Text('Criar lista', 
                          style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: _listas.length,
                          itemBuilder: (context, index) {
                            final lista = _listas[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: const Icon(Icons.list_alt, color: Color(0xFF1565C0)),
                                ),
                                title: Text(lista['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: const Text('Toque para abrir'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(listaId: lista['id'], listaNome: lista['nome']),
                                    ),
                                  );
                                },
                                onLongPress: () => _mostrarMenuDeOpcoes(context, lista),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nova Lista', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: limiteAtingido ? Colors.grey : const Color(0xFF1565C0),
        onPressed: () {
          if (limiteAtingido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Limite de 20 listas atingido!'), backgroundColor: Colors.red)
            );
          } else {
            _mostrarDialogoNovaLista(context);
          }
        },
      ),
    );
  }
// --- GAVETA DE OPÇÕES (EDITAR / EXCLUIR) ---
  void _mostrarMenuDeOpcoes(BuildContext context, Map<String, dynamic> lista) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Renomear Lista'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialogoEditarLista(context, lista);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Excluir Lista'),
                onTap: () async {
                  Navigator.pop(context);
                  final db = await BancoLocal.bancoDeDados;
                  await db.delete('listas', where: 'id = ?', whereArgs: [lista['id']]);
                  _atualizarListasNaTela();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- JANELA PARA CRIAR LISTA ---
  void _mostrarDialogoNovaLista(BuildContext context) {
    final nomeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Lista'),
          content: TextField(
            controller: nomeController, 
            decoration: const InputDecoration(labelText: 'Nome da Lista'), 
            autofocus: true
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.trim().isNotEmpty) {
                  final String novoId = const Uuid().v4();
                  final db = await BancoLocal.bancoDeDados;
                  await db.insert('listas', {
                    'id': novoId,
                    'nome': nomeController.text
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    _atualizarListasNaTela();
                  }
                }
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  // --- JANELA PARA EDITAR O NOME ---
  void _mostrarDialogoEditarLista(BuildContext context, Map<String, dynamic> lista) {
    final nomeController = TextEditingController(text: lista['nome']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Renomear Lista'),
          content: TextField(controller: nomeController, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.trim().isNotEmpty) {
                  final db = await BancoLocal.bancoDeDados;
                  await db.update('listas', {'nome': nomeController.text}, where: 'id = ?', whereArgs: [lista['id']]);
                  if (context.mounted) {
                    Navigator.pop(context);
                    _atualizarListasNaTela();
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
  
}