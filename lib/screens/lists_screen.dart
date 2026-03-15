// Arquivo: lib/screens/lists_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // O gerador de IDs únicos!
import '../dados/banco_local.dart'; // O nosso cofre!
import 'home_screen.dart';
import '../widgets/app_drawer.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  // A memória da tela que vai guardar as listas do cofre
  List<Map<String, dynamic>> _listas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _atualizarListasNaTela(); // Assim que a tela abre, busca as listas!
  }

 // --- FUNÇÃO PARA BUSCAR AS LISTAS NO CELULAR ---
  Future<void> _atualizarListasNaTela() async {
    try {
      final db = await BancoLocal.bancoDeDados;
      final listasDoBanco = await db.query('listas'); 
      
      setState(() {
        _listas = listasDoBanco;
        _carregando = false;
      });
    } catch (erro) {
      // Se der erro, ele para de girar e mostra o erro!
      setState(() { _carregando = false; });
      debugPrint('Erro no banco de dados: $erro');
    }
  }

  @override
  Widget build(BuildContext context) {
    final quantidadeDeListas = _listas.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Listas'), // Coloquei um aviso visual
      ),

      drawer: const AppDrawer(), // O MENU VOLTOU!

      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _listas.isEmpty
              ? const Center(
                  child: Text('Você ainda não tem nenhuma lista.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                )
              : Column(
                  children: [
                    // --- CABEÇALHO MOSTRANDO O LIMITE ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.blue.shade50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Uso do Aparelho:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            '$quantidadeDeListas / 20 Listas', 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: quantidadeDeListas >= 20 ? Colors.red : const Color(0xFF1565C0)
                            )
                          ),
                        ],
                      ),
                    ),

                    // --- A LISTA NA TELA ---
                    Expanded(
                      child: ListView.builder(
                        itemCount: quantidadeDeListas,
                        itemBuilder: (context, index) {
                          final lista = _listas[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.list_alt, color: Color(0xFF1565C0), size: 30),
                              title: Text(lista['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              subtitle: const Text('Toque para abrir, segure para opções'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              
                              // ENTRAR NA LISTA
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(listaId: lista['id'], listaNome: lista['nome']),
                                  ),
                                );
                              },

                              // OPÇÕES (EDITAR / EXCLUIR)
                              onLongPress: () => _mostrarMenuDeOpcoes(context, lista),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

      // --- BOTÃO DE CRIAR NOVA LISTA ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: quantidadeDeListas >= 20 ? Colors.grey : const Color(0xFF1565C0),
        onPressed: () {
          if (quantidadeDeListas >= 20) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Limite atingido! Apague uma para criar outra.'), backgroundColor: Colors.red));
          } else {
            _mostrarDialogoNovaLista(context);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
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
                  // 1. Apaga do Banco Local (O SQLite já vai apagar os produtos dela também, lembra do ON DELETE CASCADE?)
                  final db = await BancoLocal.bancoDeDados;
                  await db.delete('listas', where: 'id = ?', whereArgs: [lista['id']]);
                  // 2. Manda a tela desenhar de novo
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
          content: TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome da Lista (Ex: Feira)'), autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.trim().isNotEmpty) {
                  // 1. Cria um ID único maluco (ex: a1b2c3d4-...)
                  final String novoId = const Uuid().v4();
                  
                  // 2. Salva no Banco Local!
                  final db = await BancoLocal.bancoDeDados;
                  await db.insert('listas', {
                    'id': novoId,
                    'nome': nomeController.text
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    _atualizarListasNaTela(); // Manda a tela desenhar a nova lista
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
          content: TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Novo Nome'), autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.trim().isNotEmpty) {
                  // Atualiza no Banco Local
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