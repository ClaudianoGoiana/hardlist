// Arquivo: lib/widgets/bottom_summary_bar.dart
import 'package:flutter/material.dart';

class BottomSummaryBar extends StatelessWidget {
  const BottomSummaryBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. A MÁGICA: A barra pergunta pro aplicativo se ele está no Modo Escuro
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // 2. Se for escuro (isDark), usa um cinza elegante. Se for claro, usa o azulzinho.
      color: isDark ? const Color(0xFF1E1E1E) : Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lado Esquerdo: Total
          Row(
            children: [
              Icon(
                Icons.calculate, 
                color: isDark ? Colors.grey.shade400 : Colors.blue.shade300, 
                size: 28
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total (0)', 
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.blue.shade300, 
                      fontSize: 12
                    )
                  ),
                  Text(
                    'R\$ 0,00', 
                    style: TextStyle(
                      // Cor do dinheiro: branco no escuro, azul forte no claro
                      color: isDark ? Colors.white : const Color(0xFF1565C0), 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    )
                  ),
                ],
              ),
            ],
          ),

          // Lado Direito: Carrinho
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Carrinho (0)', 
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.blue.shade300, 
                      fontSize: 12
                    )
                  ),
                  Text(
                    'R\$ 0,00', 
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1565C0), 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    )
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.shopping_cart, 
                color: isDark ? Colors.grey.shade400 : Colors.blue.shade300, 
                size: 28
              ),
            ],
          ),
        ],
      ),
    );
  }
}