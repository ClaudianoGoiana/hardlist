// Arquivo: lib/screens/lists_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Listas'),
      ),
      // O OLHO MÁGICO OLHANDO PARA A TABELA DE LISTAS!
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('listas').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Você ainda não tem nenhuma lista.', style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          final listas = snapshot.data!;
          final quantidadeDeListas = listas.length;

          return Column(
            children: [
              // --- CABEÇALHO MOSTRANDO O LIMITE ---
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Uso da Conta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

              // --- A LISTA DE LISTAS NA TELA ---
              Expanded(
                child: ListView.builder(
                  itemCount: quantidadeDeListas,
                  itemBuilder: (context, index) {
                    final lista = listas[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.list_alt, color: Color(0xFF1565C0), size: 30),
                        title: Text(lista['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: const Text('Toque para abrir, segure para opções'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        
                        // CLIQUE NORMAL: Entrar na lista
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                listaId: lista['id'], 
                                listaNome: lista['nome']
                              ),
                            ),
                          );
                        },
                        // CLIQUE LONGO: Editar nome ou Excluir
                        onLongPress: () {
                          _mostrarMenuDeOpcoes(context, lista);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      // --- BOTÃO DE CRIAR NOVA LISTA ---
      floatingActionButton: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('listas').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          final int qtdAtual = snapshot.data?.length ?? 0;

          return FloatingActionButton(
            backgroundColor: qtdAtual >= 20 ? Colors.grey : const Color(0xFF1565C0),
            onPressed: () {
              // A TRAVA DE 20 LISTAS ACONTECE AQUI!
              if (qtdAtual >= 20) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Limite de 20 listas atingido! Apague uma para criar outra.'),
                    backgroundColor: Colors.red,
                  )
                );
              } else {
                _mostrarDialogoNovaLista(context);
              }
            },
            child: const Icon(Icons.add, color: Colors.white),
          );
        }
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
                  // Apaga a lista. (Cuidado: Como configuramos 'on delete cascade' no SQL, todos os produtos dessa lista sumirão também!)
                  await Supabase.instance.client.from('listas').delete().eq('id', lista['id']);
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
            decoration: const InputDecoration(labelText: 'Nome da Lista (Ex: Feira do Mês)'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.trim().isNotEmpty) {
                  await Supabase.instance.client.from('listas').insert({'nome': nomeController.text});
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  // --- JANELA PARA EDITAR O NOME DA LISTA ---
  void _mostrarDialogoEditarLista(BuildContext context, Map<String, dynamic> lista) {
    final nomeController = TextEditingController(text: lista['nome']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Renomear Lista'),
          content: TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: 'Novo Nome'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.trim().isNotEmpty) {
                  await Supabase.instance.client.from('listas').update({'nome': nomeController.text}).eq('id', lista['id']);
                  if (context.mounted) Navigator.pop(context);
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