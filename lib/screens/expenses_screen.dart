// Arquivo: lib/screens/expenses_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

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