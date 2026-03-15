// Arquivo: lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../main.dart'; // Importamos o main.dart para poder usar o Rádio (themeNotifier)

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // A chavinha agora começa ligada ou desligada dependendo do que o Rádio diz!
  late bool _isDarkMode; 
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Se o rádio diz que está no tema escuro, a chave começa ligada (true)
    _isDarkMode = themeNotifier.value == ThemeMode.dark; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          // --- Seção: Aparência ---
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text('Aparência', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SwitchListTile(
            title: const Text('Modo Escuro'),
            subtitle: const Text('Muda o tema do aplicativo'), // Mudei o texto aqui!
            secondary: const Icon(Icons.dark_mode),
            value: _isDarkMode,
            activeThumbColor: const Color(0xFF1565C0),
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value; // Atualiza a chavinha visualmente
              });
              
              // A MÁGICA: Pega o rádio e avisa pro main.dart mudar as cores do app inteiro!
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(),

          // --- Seção: Notificações ---
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text('Notificações', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SwitchListTile(
            title: const Text('Alertas de Compras'),
            subtitle: const Text('Lembrar de sincronizar listas'),
            secondary: const Icon(Icons.notifications_active),
            value: _notificationsEnabled,
            activeThumbColor: const Color(0xFF1565C0),
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value; 
              });
            },
          ),
          const Divider(),

          // --- Seção: Geral ---
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text('Geral', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: const Text('Português (Brasil)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Limpar todos os dados'),
            subtitle: const Text('Essa ação não pode ser desfeita'),
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}