// Arquivo: lib/screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart'; // O nosso gerador de códigos únicos!
import '../dados/catalogo_local.dart';
import '../dados/banco_local.dart'; // O nosso cofre!

class AddProductScreen extends StatefulWidget {
  final String listaId;

  const AddProductScreen({super.key, required this.listaId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final List<Map<String, String>> produtos = CatalogoLocal.produtosPadrao;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Produtos'),
      ),
      
      // --- 1. O CARDÁPIO RÁPIDO (GRID) ---
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12,
        ),
        itemCount: produtos.length,
        itemBuilder: (context, index) {
          final produto = produtos[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                // 1. Gera um ID único para este novo produto
                final String novoId = const Uuid().v4();
                
                // 2. Salva no Banco de Dados Local!
                final db = await BancoLocal.bancoDeDados;
                await db.insert('produtos', {
                  'id': novoId,
                  'lista_id': widget.listaId,
                  'nome': produto['nome'],
                  'categoria': produto['categoria'],
                  'caminho_foto_local': produto['foto'], 
                  'quantidade': '1',
                  'preco': 0.00,
                  'comprado': 0 // 0 significa 'falso' no SQLite
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${produto['nome']} adicionado!'), backgroundColor: Colors.green, duration: const Duration(seconds: 1)));
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Padding(padding: const EdgeInsets.all(12.0), child: Image.asset(produto['foto']!, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)))),
                  Padding(padding: const EdgeInsets.only(bottom: 12.0, left: 8.0, right: 8.0), child: Text(produto['nome']!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), decoration: const BoxDecoration(color: Color(0xFF1565C0), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))), child: const Icon(Icons.add_shopping_cart, color: Colors.white))
                ],
              ),
            ),
          );
        },
      ),

      // --- 2. O BOTÃO PARA PRODUTOS EXCLUSIVOS DO USUÁRIO ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirCriadorDeProdutoPersonalizado(context),
        backgroundColor: Colors.orange.shade700, 
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text('Novo Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- 3. A GAVETA PARA CRIAR O PRODUTO PERSONALIZADO ---
  void _abrirCriadorDeProdutoPersonalizado(BuildContext context) {
    final nomeController = TextEditingController();
    String categoriaSelecionada = 'Outros';
    String? caminhoFotoPersonalizada;
    final ImagePicker picker = ImagePicker();
    
    final List<String> categorias = ['Mercearia', 'Açougue', 'Hortifruti', 'Frios e Laticínios', 'Bebidas', 'Limpeza', 'Higiene', 'Padaria', 'Outros'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Produto Personalizado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  GestureDetector(
                    onTap: () async {
                      final XFile? foto = await picker.pickImage(source: ImageSource.camera);
                      if (foto != null) {
                        setStateBottomSheet(() { caminhoFotoPersonalizada = foto.path; });
                      }
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: caminhoFotoPersonalizada != null ? FileImage(File(caminhoFotoPersonalizada!)) : null,
                      child: caminhoFotoPersonalizada == null ? const Icon(Icons.camera_alt, size: 30, color: Colors.grey) : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Produto', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    initialValue: categoriaSelecionada,
                    decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                    items: categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (valor) => setStateBottomSheet(() { categoriaSelecionada = valor!; }),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: () async {
                        if (nomeController.text.trim().isEmpty) return;

                        // 1. Gera ID único para a foto do cliente
                        final String novoId = const Uuid().v4();

                        // 2. Salva no Banco Local!
                        final db = await BancoLocal.bancoDeDados;
                        await db.insert('produtos', {
                          'id': novoId,
                          'lista_id': widget.listaId,
                          'nome': nomeController.text,
                          'categoria': categoriaSelecionada,
                          'caminho_foto_local': caminhoFotoPersonalizada, 
                          'quantidade': '1',
                          'preco': 0.00,
                          'comprado': 0
                        });

                        if (context.mounted) {
                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item personalizado salvo!'), backgroundColor: Colors.green));
                        }
                      },
                      child: const Text('Salvar na Lista', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      }
    );
  }
}