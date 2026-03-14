// Arquivo: lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'history_detail_screen.dart'; // Importamos a tela de detalhes para poder navegar até ela

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulando os dados do histórico baseados na sua Imagem 7
    final List<Map<String, String>> historico = [
      {'nome': '04 09 25', 'data': '04/09/2025', 'valor': 'R\$ 704,20'},
      {'nome': 'Jjjjjjjjj', 'data': '02/09/2025', 'valor': 'R\$ 179,80'},
      {'nome': 'Hhhhhhh', 'data': '02/09/2025', 'valor': 'R\$ 125,90'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de compras'),
        actions: [
          // Ícone de Informação
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
          // Ícone de Gráfico
          IconButton(icon: const Icon(Icons.insert_chart), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // --- 1. A Lista de Histórico ---
          // Usamos Expanded para a lista ocupar todo o espaço disponível até o banner
          Expanded(
            child: ListView.separated(
              itemCount: historico.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
              itemBuilder: (context, index) {
                final item = historico[index];
                return ListTile(
                  // title: O texto principal (nome da lista)
                  title: Text(item['nome']!, style: const TextStyle(fontSize: 16)),
                  
                  // subtitle: O texto menor que fica embaixo do title (a data)
                  subtitle: Text(item['data']!, style: const TextStyle(color: Colors.grey)),
                  
                  // trailing: O que fica grudado no lado direito (o valor)
                  trailing: Text(
                    item['valor']!, 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                  
                  onTap: () {
                 // Navega para a tela de detalhes
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     // Aqui está o segredo: passamos os dados do item clicado para a nova tela!
                     builder: (context) => HistoryDetailScreen(
                       nomeDaLista: item['nome']!,
                       dataDaLista: item['data']!,
                       valorDaLista: item['valor']!,
                     ),
                   ),
                 );
               },
                );
              },
            ),
          ),
          
          // --- 2. Banner Inferior (Aviso da Nuvem) ---
          Container(
            color: const Color(0xFFBBDEFB), // Nosso fundo azul clarinho
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.cloud_upload, color: Color(0xFF1565C0)), // Ícone de nuvem
                const SizedBox(width: 12),
                // Usamos Expanded no texto para ele não empurrar o botão "X" para fora da tela
                const Expanded(
                  child: Text(
                    'Mantenha todos os seus históricos de compras salvos na nuvem. Saiba mais.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                // Botão de fechar (X)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () {
                    print("Fechar aviso");
                    // No futuro, isso fará a barra sumir
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}