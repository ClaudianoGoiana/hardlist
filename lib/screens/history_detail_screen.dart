// Arquivo: lib/screens/history_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';

class HistoryDetailScreen extends StatelessWidget {
  final String nomeDaLista;
  final String dataDaLista;
  final String valorDaLista;
  final String produtosJson;

  const HistoryDetailScreen({
    super.key,
    required this.nomeDaLista,
    required this.dataDaLista,
    required this.valorDaLista,
    required this.produtosJson,
  });

  String _formatarData(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year;
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$d/$m/$y às $h:$min';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> produtos = jsonDecode(produtosJson);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Compra'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: Column(
        children: [
          // Cabeçalho com nome, data e total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1565C0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomeDaLista,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatarData(dataDaLista),
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total: $valorDaLista',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                  ),
                ),
              ],
            ),
          ),

          // Lista de produtos comprados
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Color(0xFF1565C0), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Itens comprados (${produtos.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: produtos.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final p = produtos[index] as Map<String, dynamic>;
                final nome = p['nome']?.toString() ?? '';
                final qtd = p['quantidade']?.toString() ?? '1';
                final preco = (p['preco'] as num?)?.toDouble() ?? 0.0;
                final qtdNum = int.tryParse(qtd) ?? 1;
                final subtotal = preco * qtdNum;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(nome, style: const TextStyle(fontSize: 15)),
                  subtitle: Text(
                    'Qtd: $qtd  ×  R\$ ${preco.toStringAsFixed(2).replaceAll(".", ",")}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  trailing: Text(
                    'R\$ ${subtotal.toStringAsFixed(2).replaceAll(".", ",")}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}