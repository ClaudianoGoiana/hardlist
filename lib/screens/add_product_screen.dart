// Arquivo: lib/screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
  final List<String> _categorias = [
    'Todas',
    'Açougue',
    'Bebidas',
    'Frios e Laticínios',
    'Higiene',
    'Hortifruti',
    'Limpeza',
    'Mercearia',
    'Outros',
    'Padaria',
  ];
  String _categoriaSelecionada = 'Todas';
  String _textoBusca = '';

  Future<String?> _capturarERecortarFoto(ImagePicker picker) async {
    try {
      final XFile? foto = await picker.pickImage(source: ImageSource.camera);
      if (foto == null) return null;

      final CroppedFile? fotoRecortada = await ImageCropper().cropImage(
        sourcePath: foto.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar foto',
            toolbarColor: const Color(0xFF1565C0),
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(title: 'Recortar foto'),
        ],
      );

      // Se o usuário cancelar o recorte, mantém a foto original capturada.
      return fotoRecortada?.path ?? foto.path;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao abrir recorte: $e')));
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final produtosFiltrados = produtos.where((produto) {
      final nome = (produto['nome'] ?? '').toLowerCase();
      final busca = _textoBusca.toLowerCase();

      final passouBusca = nome.contains(busca);
      final passouCategoria =
          _categoriaSelecionada == 'Todas' ||
          produto['categoria'] == _categoriaSelecionada;

      return passouBusca && passouCategoria;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Produtos')),

      // --- 1. O CARDÁPIO RÁPIDO (GRID) ---
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar produto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (valor) {
                setState(() => _textoBusca = valor);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: DropdownButtonFormField<String>(
              initialValue: _categoriaSelecionada,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              items: _categorias
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (valor) {
                if (valor == null) return;
                setState(() => _categoriaSelecionada = valor);
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: produtosFiltrados.length,
              itemBuilder: (context, index) {
                final produto = produtosFiltrados[index];
                final caminhoFoto =
                    produto['foto'] ??
                    CatalogoLocal.caminhoFotoPadrao(produto['nome'] ?? '');
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final String novoId = const Uuid().v4();

                      final db = await BancoLocal.bancoDeDados;
                      await db.insert('produtos', {
                        'id': novoId,
                        'lista_id': widget.listaId,
                        'nome': produto['nome'],
                        'categoria': produto['categoria'],
                        'caminho_foto_local': caminhoFoto,
                        'quantidade': '1',
                        'preco': 0.00,
                        'comprado': 0,
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${produto['nome']} adicionado!'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                caminhoFoto,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.shopping_bag,
                                  size: 50,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12.0,
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: Text(
                            produto['nome']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1565C0),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // --- 2. O BOTÃO PARA PRODUTOS EXCLUSIVOS DO USUÁRIO ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirCriadorDeProdutoPersonalizado(context),
        backgroundColor: Colors.orange.shade700,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text(
          'Novo Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- 3. A GAVETA PARA CRIAR O PRODUTO PERSONALIZADO ---
  void _abrirCriadorDeProdutoPersonalizado(BuildContext context) {
    final nomeController = TextEditingController();
    String categoriaSelecionada = 'Outros';
    String? caminhoFotoPersonalizada;
    final ImagePicker picker = ImagePicker();

    final List<String> categorias = [
      'Mercearia',
      'Açougue',
      'Hortifruti',
      'Frios e Laticínios',
      'Bebidas',
      'Limpeza',
      'Higiene',
      'Padaria',
      'Outros',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Produto Personalizado',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () async {
                      final String? fotoPath = await _capturarERecortarFoto(
                        picker,
                      );
                      if (fotoPath != null) {
                        setStateBottomSheet(() {
                          caminhoFotoPersonalizada = fotoPath;
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: caminhoFotoPersonalizada != null
                          ? FileImage(File(caminhoFotoPersonalizada!))
                          : null,
                      child: caminhoFotoPersonalizada == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Produto',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: categoriaSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: categorias
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (valor) => setStateBottomSheet(() {
                      categoriaSelecionada = valor!;
                    }),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
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
                          'comprado': 0,
                        });

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item personalizado salvo!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Salvar na Lista',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
