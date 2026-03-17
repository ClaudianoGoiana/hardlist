// Arquivo: lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import '../dados/banco_local.dart';
import 'history_detail_screen.dart'; // Importamos a tela de detalhes para poder navegar até ela

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historicoFuture;

  @override
  void initState() {
    super.initState();
    _historicoFuture = BancoLocal.listarHistorico();
  }

  Future<void> _refresh() async {
    setState(() {
      _historicoFuture = BancoLocal.listarHistorico();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de compras'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historicoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            final historico = snapshot.data ?? [];
            if (historico.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Nenhuma compra confirmada ainda. Faça uma lista, marque os itens no carrinho e confirme a compra para ver o histórico aqui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: historico.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
              itemBuilder: (context, index) {
                final item = historico[index];
                final valor = (item['valor'] as num?)?.toDouble() ?? 0.0;

                return ListTile(
                  title: Text(item['nome']?.toString() ?? '', style: const TextStyle(fontSize: 16)),
                  subtitle: Text(item['data']?.toString() ?? '', style: const TextStyle(color: Colors.grey)),
                  trailing: Text(
                    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryDetailScreen(
                          nomeDaLista: item['nome']?.toString() ?? '',
                          dataDaLista: item['data']?.toString() ?? '',
                          valorDaLista: 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
                          produtosJson: item['produtos_json']?.toString() ?? '[]',
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}