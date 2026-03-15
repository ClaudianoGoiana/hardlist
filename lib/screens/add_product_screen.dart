// Arquivo: lib/screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductScreen extends StatefulWidget {
  final String listaId; // AGORA A TELA EXIGE A ETIQUETA DA LISTA!

  const AddProductScreen({super.key, required this.listaId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController(text: '1');
  final _precoController = TextEditingController();
  
  String _categoriaSelecionada = 'Mercearia';
  String? _caminhoDaFoto;

  final List<String> _categorias = [
    'Mercearia', 'Açougue', 'Hortifruti', 'Frios e Laticínios', 
    'Bebidas', 'Limpeza', 'Higiene', 'Padaria', 'Outros'
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _escolherFoto(ImageSource origem) async {
    final XFile? fotoEscolhida = await _picker.pickImage(source: origem);
    if (fotoEscolhida != null) {
      setState(() {
        _caminhoDaFoto = fotoEscolhida.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- FOTO DO PRODUTO ---
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: _caminhoDaFoto != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(File(_caminhoDaFoto!), fit: BoxFit.cover),
                          )
                        : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: -10, right: -10,
                    child: IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: Color(0xFF1565C0),
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeria'), onTap: () { Navigator.pop(context); _escolherFoto(ImageSource.gallery); }),
                                ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Câmera'), onTap: () { Navigator.pop(context); _escolherFoto(ImageSource.camera); }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- CAMPOS DE TEXTO ---
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do Produto', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _quantidadeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qtd.', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _precoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Preço Estimado', prefixText: 'R\$ ', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _categoriaSelecionada,
              decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
              items: _categorias.map((String categoria) {
                return DropdownMenuItem(value: categoria, child: Text(categoria));
              }).toList(),
              onChanged: (String? novaCategoria) {
                setState(() { _categoriaSelecionada = novaCategoria!; });
              },
            ),
            const SizedBox(height: 32),

            // --- BOTÃO DE SALVAR ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (_nomeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, digite o nome do produto.')));
                  return;
                }

                String precoTexto = _precoController.text.replaceAll(',', '.');
                double precoFinal = double.tryParse(precoTexto) ?? 0.0;

                // A MÁGICA FINAL: Inserindo no banco de dados com a etiqueta widget.listaId !
                await Supabase.instance.client.from('produtos').insert({
                  'lista_id': widget.listaId, // <--- AQUI ELE PEGA O ID CORRETO DA LISTA ATUAL
                  'nome': _nomeController.text,
                  'categoria': _categoriaSelecionada,
                  'quantidade': _quantidadeController.text,
                  'preco': precoFinal,
                  'caminho_foto_local': _caminhoDaFoto,
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto salvo!'), backgroundColor: Colors.green));
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar Produto', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}