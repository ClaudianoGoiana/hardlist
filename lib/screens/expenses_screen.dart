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

  @override
  Widget build(BuildContext context) {
    // Lista com as despesas e as cores para a legenda
    final List<Map<String, dynamic>> listaDespesas = [
      {'nome': 'Sem categoria', 'valor': '244,62', 'pct': '24%', 'cor': Colors.green.shade400},
      {'nome': 'Mercearia', 'valor': '238,60', 'pct': '24%', 'cor': Colors.blue.shade400},
      {'nome': 'Carnes', 'valor': '213,00', 'pct': '21%', 'cor': Colors.orange.shade400},
      {'nome': 'Frios, leites e derivados', 'valor': '180,39', 'pct': '18%', 'cor': Colors.red.shade400},
      {'nome': 'Bazar e limpeza', 'valor': '57,67', 'pct': '6%', 'cor': Colors.teal.shade400},
      {'nome': 'Frutas, ovos e verduras', 'valor': '35,00', 'pct': '3%', 'cor': Colors.purple.shade400},
    ];

    // DefaultTabController é quem gerencia as abas (Categorias, Lojas, Produtos)
    return DefaultTabController(
      length: 3, // Quantidade de abas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minhas despesas'),
          actions: [
            IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            
            // --- 1. Filtro de Data ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('01/09/2025 - 05/09/2025', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            
            // --- 2. Total ---
            const Text('Total', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const Text('R\$ 1.009,90', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // --- 3. As Abas (Tabs) ---
            const TabBar(
              labelColor: Color(0xFF1565C0), // Nosso azul quando selecionado
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF1565C0),
              tabs: [
                Tab(text: 'CATEGORIAS'),
                Tab(text: 'LOJAS'),
                Tab(text: 'PRODUTOS'),
              ],
            ),
            
            // --- 4. O Conteúdo das Abas ---
            Expanded(
              child: TabBarView(
                children: [
                  // Aba 1: Categorias (A que vamos construir agora)
                  _buildCategoriasView(listaDespesas),
                  
                  // Aba 2: Lojas (Em branco por enquanto)
                  const Center(child: Text('Lojas: Em construção...')),
                  
                  // Aba 3: Produtos (Em branco por enquanto)
                  const Center(child: Text('Produtos: Em construção...')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função que constrói o visual da aba "Categorias"
  Widget _buildCategoriasView(List<Map<String, dynamic>> despesas) {
    return Column(
      children: [
        // Botãozinho verde/azul de alternar gráfico da imagem
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0), // Azul
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.pie_chart, color: Colors.white), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.bar_chart, color: Colors.white54), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
        
        // O Gráfico de Rosquinha (Donut)
        SizedBox(
          height: 180,
          width: 180,
          child: CustomPaint(
            painter: DonutChartPainter(),
          ),
        ),
        const SizedBox(height: 20),
        
        // Cabecalho da lista (R$)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text('(R\$) ', style: TextStyle(fontWeight: FontWeight.bold))],
          ),
        ),
        
        // A lista com as legendas e valores
        Expanded(
          child: ListView.builder(
            itemCount: despesas.length,
            itemBuilder: (context, index) {
              final item = despesas[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Quadrado colorido
                    Container(width: 16, height: 16, color: item['cor']),
                    const SizedBox(width: 10),
                    // Nome da categoria
                    Expanded(child: Text(item['nome'], style: const TextStyle(fontSize: 16))),
                    // Valor em Reais
                    SizedBox(
                      width: 80, 
                      child: Text(item['valor'], textAlign: TextAlign.right, style: const TextStyle(fontSize: 16))
                    ),
                    const SizedBox(width: 20),
                    // Porcentagem
                    SizedBox(
                      width: 40,
                      child: Text(item['pct'], textAlign: TextAlign.right, style: const TextStyle(fontSize: 16))
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }


// ==========================================
// A MÁGICA DO GRÁFICO (CustomPainter)
// Esta classe desenha o círculo colorido na tela!
// ==========================================
class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Definimos as fatias do gráfico (Porcentagens: 24, 24, 21, 18, 6, 3)
    final sweepAngles = [
      24 / 100 * 2 * pi, // Verde
      24 / 100 * 2 * pi, // Azul
      21 / 100 * 2 * pi, // Laranja
      18 / 100 * 2 * pi, // Vermelho
      6 / 100 * 2 * pi,  // Teal (Verde água)
      7 / 100 * 2 * pi,  // Roxo (ajustado para fechar o círculo)
    ];

    final colors = [
      Colors.green.shade400,
      Colors.blue.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.purple.shade400,
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke // Faz ser uma "rosquinha" (apenas borda)
      ..strokeWidth = 40.0; // Espessura da rosquinha

    double startAngle = -pi / 2; // Começa a desenhar no topo (12 horas)

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    for (int i = 0; i < sweepAngles.length; i++) {
      paint.color = colors[i];
      canvas.drawArc(rect, startAngle, sweepAngles[i], false, paint);
      startAngle += sweepAngles[i]; // Avança para a próxima fatia
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}