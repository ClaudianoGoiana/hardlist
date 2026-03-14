// Arquivo: lib/widgets/bottom_summary_bar.dart
import 'package:flutter/material.dart';

class BottomSummaryBar extends StatelessWidget {
  const BottomSummaryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFBBDEFB), // Fundo azul claro
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Usamos uma função para criar os itens, economizando código!
          _buildSummaryItem(icon: Icons.calculate, title: "Total (0)", value: "R\$ 0,00"),
          _buildSummaryItem(icon: Icons.shopping_cart, title: "Carrinho (0)", value: "R\$ 0,00"),
        ],
      ),
    );
  }

  // Função auxiliar que "monta" o visual do Total e do Carrinho
  Widget _buildSummaryItem({required IconData icon, required String title, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 30),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}