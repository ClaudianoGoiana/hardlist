// Arquivo: lib/screens/cloud_screen.dart
import 'package:flutter/material.dart';

class CloudScreen extends StatelessWidget {
  // 1. Criamos as "gavetas" (variáveis) para receber os dados do usuário logado
  final String nomeUsuario;
  final String emailUsuario;

  // 2. O construtor agora pede esses dados na hora de abrir a tela
  const CloudScreen({
    super.key,
    required this.nomeUsuario,
    required this.emailUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HardList Cloud'),
        backgroundColor: const Color(0xFF1565C0), 
      ),
      body: Column(
        children: [
          // --- 1. Cabeçalho do Usuário (Agora é Dinâmico!) ---
          Container(
            color: Colors.grey.shade200, 
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Usamos a variável do nome em vez do texto fixo!
                      Text(
                        nomeUsuario,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      // Usamos a variável do email (e se estiver vazio, nem mostramos a linha)
                      if (emailUsuario.isNotEmpty) 
                        Text(
                          emailUsuario,
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                    ],
                  ),
                ),
                
                IconButton(
                  icon: const Icon(Icons.notifications_off, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // --- 2. Menu de Ações da Nuvem ---
          _buildCloudOption(icon: Icons.person_add, text: 'Adicionar conta', onTap: () {}),
          const Divider(height: 1),
          _buildCloudOption(icon: Icons.settings, text: 'Gerenciar contas', onTap: () {}),
          const Divider(height: 1),
          _buildCloudOption(icon: Icons.person, text: 'Selecionar conta', onTap: () {}),
          const Divider(height: 1),
          _buildCloudOption(icon: Icons.vpn_key, text: 'Alterar senha', onTap: () {}),
          const Divider(height: 1),
          _buildCloudOption(icon: Icons.sync, text: 'Sincronizar', onTap: () {}),
          const Divider(height: 1),

          const Spacer(),

          // --- 3. Rodapé ---
          Container(
            width: double.infinity,
            color: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: const Text(
              'Última sincronização: 14/03/2026 02:29:45',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudOption({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}