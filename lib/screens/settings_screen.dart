import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Para acessar themeNotifier global
import 'login_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // A chavinha agora começa ligada ou desligada dependendo do que o Rádio diz!
  late bool _isDarkMode; 
  bool _notificationsEnabled = true;
  bool _deletandoConta = false;

  @override
  void initState() {
    super.initState();
    // Se o rádio diz que está no tema escuro, a chave começa ligada (true)
    _isDarkMode = themeNotifier.value == ThemeMode.dark; 
  }

  Future<void> _confirmarExclusaoConta() async {
    final confirmar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Excluir conta'),
            content: const Text(
              'Essa ação vai excluir sua conta e remover seu acesso ao HardList. '
              'Deseja continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar || !mounted) return;

    setState(() {
      _deletandoConta = true;
    });

    try {
      final response = await Supabase.instance.client.functions.invoke('delete-account');

      if (response.status != 200) {
        final errorMessage = response.data is Map<String, dynamic>
            ? (response.data['error']?.toString() ?? 'Falha ao excluir conta.')
            : 'Falha ao excluir conta.';
        throw Exception(errorMessage);
      }

      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta excluída com sucesso.')),
      );
    } catch (e) {
      final errorText = e.toString();
      final message = errorText.contains('404') || errorText.contains('FunctionsHttpError')
          ? 'A funcao de exclusao ainda nao foi publicada no Supabase.'
          : 'Erro ao excluir conta: $e';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletandoConta = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email ?? 'Não informado';

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

          if (user != null) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text('Conta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Conta conectada'),
              subtitle: Text(userEmail),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Excluir minha conta'),
              subtitle: Text(_deletandoConta ? 'Excluindo conta...' : 'Remove o acesso do usuário ao aplicativo'),
              iconColor: Colors.red,
              textColor: Colors.red,
              enabled: !_deletandoConta,
              onTap: _deletandoConta ? null : _confirmarExclusaoConta,
            ),
            const Divider(),
          ],

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
        ],
      ),
    );
  }
}