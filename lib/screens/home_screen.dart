// Arquivo: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bottom_summary_bar.dart'; // Importamos a nossa nova pecinha!

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String nomeListaAtual = 'Maria';

  // --- Função separada apenas para construir o Menu de Listas ---
  // Tiramos esse código gigante do meio da tela principal para ficar limpo
  Widget _buildDropdownListas() {
    return PopupMenuButton<String>(
      onSelected: (String escolha) {
        if (escolha != 'gerenciar' && escolha != 'criar') {
          setState(() { nomeListaAtual = escolha; });
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(nomeListaAtual, style: const TextStyle(fontSize: 20)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem(enabled: false, child: Text('Listas', style: TextStyle(fontWeight: FontWeight.bold))),
        const PopupMenuItem(value: 'Maria', child: Text('Maria')),
        const PopupMenuItem(value: 'Feira Do Mês', child: Text('Feira Do Mês')),
        const PopupMenuItem(value: 'Minha lista', child: Text('Minha lista')),
        const PopupMenuItem(enabled: false, child: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
        const PopupMenuItem(value: 'gerenciar', child: Text('Gerenciador de Listas')),
        const PopupMenuItem(value: 'criar', child: Text('Criar nova lista')),
      ],
    );
  }

  // --- O desenho principal da tela ---
  // Olha como ficou fácil de ler agora!
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildDropdownListas(), // Chamamos a função que criamos acima
        actions: [
          IconButton(icon: const Icon(Icons.playlist_add), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      drawer: const AppDrawer(), // Nossa pecinha do Menu Lateral
      
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.turn_right, size: 80, color: Colors.grey),
            Text('Adicione produtos\nà sua lista.', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, color: Colors.grey)),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1976D2),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      
      // Chamamos a nossa nova pecinha da barra inferior! Uma linha só!
      bottomNavigationBar: const BottomSummaryBar(), 
    );
  }
}