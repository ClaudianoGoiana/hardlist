// Arquivo: lib/screens/expenses_screen.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../dados/banco_local.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool _mostrarRosquinha = true; // true = donut, false = barras
  late Future<List<Map<String, dynamic>>> _despesasFuture;

  // Cores fixas por categoria
  final Map<String, Color> _coresPorCategoria = {
    'Mercearia': Colors.blue.shade400,
    'Açougue': Colors.orange.shade400,
    'Hortifruti': Colors.green.shade500,
    'Frios e Laticínios': Colors.cyan.shade400,
    'Bebidas': Colors.purple.shade400,
    'Limpeza': Colors.teal.shade400,
    'Higiene': Colors.pink.shade300,
    'Padaria': Colors.amber.shade600,
    'Outros': Colors.grey.shade400,
  };

  @override
  void initState() {
    super.initState();
    _despesasFuture = _calcularDespesas();
  }

  Future<List<Map<String, dynamic>>> _calcularDespesas() async {
    final historico = await BancoLocal.listarHistorico();

    final Map<String, double> totalPorCategoria = {};

    for (final compra in historico) {
      final produtosJson = compra['produtos_json']?.toString() ?? '[]';
      final List<dynamic> produtos = jsonDecode(produtosJson);
      for (final p in produtos) {
        final categoria = p['categoria']?.toString() ?? 'Outros';
        final preco = (p['preco'] as num?)?.toDouble() ?? 0.0;
        final qtd = int.tryParse(p['quantidade']?.toString() ?? '1') ?? 1;
        totalPorCategoria[categoria] = (totalPorCategoria[categoria] ?? 0) + preco * qtd;
      }
    }

    if (totalPorCategoria.isEmpty) return [];

    final total = totalPorCategoria.values.fold(0.0, (a, b) => a + b);

    final lista = totalPorCategoria.entries.map((e) {
      final pct = total > 0 ? (e.value / total * 100).round() : 0;
      return {
        'nome': e.key,
        'valor': e.value,
        'pct': pct,
        'cor': _coresPorCategoria[e.key] ?? Colors.grey.shade400,
      };
    }).toList();

    // Ordena do maior para o menor valor
    lista.sort((a, b) => (b['valor'] as double).compareTo(a['valor'] as double));

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Despesas'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _despesasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final despesas = snapshot.data ?? [];
          final total = despesas.fold<double>(0, (s, e) => s + (e['valor'] as double));

          if (despesas.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhuma despesa registrada.\nConfirme uma compra na lista para ver as despesas aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return Column(
            children: [
              const SizedBox(height: 16),

              // --- TOTAL ---
              const Text('Total gasto', style: TextStyle(fontSize: 15, color: Colors.grey)),
              Text(
                'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
              ),
              const SizedBox(height: 16),

              // --- ALTERNADOR DE GRÁFICO ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _botaoGrafico(
                      icone: Icons.pie_chart,
                      ativo: _mostrarRosquinha,
                      onTap: () => setState(() => _mostrarRosquinha = true),
                      label: 'Pizza',
                    ),
                    _botaoGrafico(
                      icone: Icons.bar_chart,
                      ativo: !_mostrarRosquinha,
                      onTap: () => setState(() => _mostrarRosquinha = false),
                      label: 'Barras',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- GRÁFICO ---
              _mostrarRosquinha
                  ? _buildDonut(despesas, total)
                  : _buildBarras(despesas, total),

              const SizedBox(height: 16),

              // --- CABEÇALHO DA LISTA ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(child: Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13))),
                    SizedBox(width: 90, child: Text('Valor (R\$)', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13))),
                    SizedBox(width: 50, child: Text('%', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13))),
                  ],
                ),
              ),
              const Divider(height: 8),

              // --- LISTA DE CATEGORIAS ---
              Expanded(
                child: ListView.builder(
                  itemCount: despesas.length,
                  itemBuilder: (context, index) {
                    final item = despesas[index];
                    final valor = item['valor'] as double;
                    final pct = item['pct'] as int;
                    final cor = item['cor'] as Color;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                      child: Row(
                        children: [
                          Container(width: 14, height: 14, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3))),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item['nome'] as String, style: const TextStyle(fontSize: 15))),
                          SizedBox(
                            width: 90,
                            child: Text(
                              valor.toStringAsFixed(2).replaceAll('.', ','),
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '$pct%',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _botaoGrafico({required IconData icone, required bool ativo, required VoidCallback onTap, required String label}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: ativo ? const Color(0xFF1565C0) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icone, color: ativo ? Colors.white : Colors.grey.shade600, size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: ativo ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDonut(List<Map<String, dynamic>> despesas, double total) {
    return SizedBox(
      height: 180,
      width: 180,
      child: CustomPaint(
        painter: _DonutPainter(despesas, total),
      ),
    );
  }

  Widget _buildBarras(List<Map<String, dynamic>> despesas, double total) {
    final maxValor = (despesas.first['valor'] as double);
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: despesas.length,
        itemBuilder: (context, index) {
          final item = despesas[index];
          final valor = item['valor'] as double;
          final cor = item['cor'] as Color;
          final alturaMaxima = 140.0;
          final altura = maxValor > 0 ? (valor / maxValor) * alturaMaxima : 0.0;
          final nome = (item['nome'] as String).split(' ').first; // Abreviado

          return Container(
            width: 58,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'R\$${valor.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 36,
                  height: altura,
                  decoration: BoxDecoration(
                    color: cor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nome,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> despesas;
  final double total;

  _DonutPainter(this.despesas, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 38.0;

    double startAngle = -pi / 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    for (final item in despesas) {
      final valor = item['valor'] as double;
      final sweep = total > 0 ? (valor / total) * 2 * pi : 0.0;
      paint.color = item['cor'] as Color;
      canvas.drawArc(rect, startAngle, sweep - 0.03, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.despesas != despesas;
}