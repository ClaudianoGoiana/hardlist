// Arquivo: lib/screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // O pacote da câmera que acabamos de instalar!
import 'package:flutter/foundation.dart' show kIsWeb; // Traz o superpoder de saber se é Web ou não (para lidar com fotos no Web de forma diferente)

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Variável que vai guardar o CAMINHO da foto no celular (é isso que vai pro Banco de Dados depois!)
  String? _caminhoDaFoto;

  // Controladores para pegar o texto que o usuário digitar
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  final _quantidadeController = TextEditingController();

  // O "Motor" da câmera
  final ImagePicker _picker = ImagePicker();

  // Função Mágica: Abre a câmera ou galeria e pega a foto
  Future<void> _escolherFoto(ImageSource origem) async {
    final XFile? fotoEscolhida = await _picker.pickImage(source: origem);

    if (fotoEscolhida != null) {
      setState(() {
        _caminhoDaFoto = fotoEscolhida.path; // Salva o caminho local do arquivo!
      });
      print("Caminho da foto para salvar no Banco: $_caminhoDaFoto");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se estamos no Modo Escuro (para ajustar as cores)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- ÁREA DA FOTO ---
            GestureDetector(
              onTap: () {
                // Ao clicar, mostra opções: Câmera ou Galeria
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Tirar Foto'),
                          onTap: () {
                            Navigator.pop(context);
                            _escolherFoto(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Escolher da Galeria'),
                          onTap: () {
                            Navigator.pop(context);
                            _escolherFoto(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1565C0), width: 2),
                ),
                child: _caminhoDaFoto != null
                    // Se tem foto, mostra ela lendo do arquivo local (Image.file)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: kIsWeb 
                            ? Image.network(
                                _caminhoDaFoto!, 
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_caminhoDaFoto!),
                                fit: BoxFit.cover,
                              ),
                      )
                    // Se não tem foto, mostra o ícone de adicionar
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: isDark ? Colors.grey.shade400 : const Color(0xFF1565C0)),
                          const SizedBox(height: 8),
                          Text('Adicionar Foto', style: TextStyle(color: isDark ? Colors.grey.shade400 : const Color(0xFF1565C0))),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // --- FORMULÁRIO DE DADOS ---
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Produto (ex: Arroz 5kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantidadeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _precoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Preço (R\$)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- BOTÃO SALVAR ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
              ),
              onPressed: () { // <-- MUDAMOS AQUI DE onTap PARA onPressed!
                // Aqui futuramente enviaremos os textos para o Supabase!
                print("SALVANDO NO BANCO DE DADOS...");
                print("Nome: ${_nomeController.text}");
                print("Preço: ${_precoController.text}");
                print("Qtd: ${_quantidadeController.text}");
                print("Caminho da Foto: $_caminhoDaFoto"); 
                
                // Fecha a tela e volta pra lista
                Navigator.pop(context);
              },
              child: const Text('Salvar Produto', style: TextStyle(fontSize: 18)),
            ),
          ),
          ],
        ),
      ),
    );
  }
}