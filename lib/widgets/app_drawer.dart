import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/products_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/expenses_screen.dart';
import '../screens/login_screen.dart';
import '../screens/history_screen.dart';
import '../screens/cloud_screen.dart';
import '../screens/list_screen.dart';
import '../screens/received_lists_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';

// Widget do Menu Lateral
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = snapshot.data?.session?.user;
        final userName = user?.userMetadata?['name'] ?? user?.email?.split('@').first ?? 'Usuário';
        final userEmail = user?.email ?? '';

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Cabeçalho com informações do usuário ou login
              if (user != null)
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1565C0),
                  ),
                  accountName: Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  accountEmail: Text(userEmail),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                )
              else
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF1565C0),
                    ),
                    accountName: Text(
                      "Fazer Login",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    accountEmail: Text("Clique aqui para acessar sua conta"),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.login, size: 40, color: Colors.grey),
                    ),
                  ),
                ),

              // Itens do menu sempre visíveis, mas alguns só para logados
              // Lista de opções do menu lateral (limpa e atualizada)
              _buildDrawerItem(
                icon: Icons.list_alt, 
                text: 'Listas', 
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  Navigator.push( // Abre a tela de Listas
                    context,
                    MaterialPageRoute(builder: (context) => const ListScreen()),
                  );
                }
              ),
              _buildDrawerItem(
                icon: Icons.inventory, 
                text: 'Produtos', 
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  Navigator.push( // Abre a tela de Produtos
                    context,
                    MaterialPageRoute(builder: (context) => const ProductsScreen()),
                  );
                }
              ),
              // ... (dentro da ListView do app_drawer) ...
              _buildDrawerItem(
                icon: Icons.format_list_bulleted, 
                text: 'Categorias', 
                onTap: () {
                  // 1. Fecha o menu lateral
                  Navigator.pop(context); 
                  // 2. Navega para a tela de Categorias
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoriesScreen()),
                  );
                }
              ),
              _buildDrawerItem(
                icon: Icons.history, 
                text: 'Histórico de compras', 
                onTap: () {
                  // 1. Fecha o menu lateral
                  Navigator.pop(context); 
                  // 2. Abre a tela de Histórico
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                }
              ),
              _buildDrawerItem(
                icon: Icons.attach_money, 
                text: 'Minhas despesas', 
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  Navigator.push( // Abre a tela
                    context,
                    MaterialPageRoute(builder: (context) => const ExpensesScreen()),
                  );
                }
              ),

              const Divider(), // Linha divisória
              _buildDrawerItem(
                icon: Icons.mark_email_unread, 
                text: 'Listas recebidas', 
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  Navigator.push( // Abre a tela
                    context,
                    MaterialPageRoute(builder: (context) => const ReceivedListsScreen()),
                  );
                }
              ),
              
              // HardList Cloud só para logados
              if (user != null)
                _buildDrawerItem(
                  icon: Icons.cloud, 
                  text: 'HardList Cloud', 
                  onTap: () {
                    Navigator.pop(context); // Fecha o menu lateral
                    Navigator.push( 
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CloudScreen(),
                      ),
                    );
                  }
                ),
              
              const Divider(), // Linha divisória
              _buildDrawerItem(
                icon: Icons.settings, 
                text: 'Configurações', 
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  Navigator.push( // Abre a tela de Configurações
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                }
              ),
              _buildDrawerItem(
                icon: Icons.info_outline, 
                text: 'Sobre', 
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  Navigator.push( // Abre a tela Sobre
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                }
              ),
              
              // Sair só para logados
              if (user != null) ...[
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  text: 'Sair',
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    Navigator.pop(context); // Fecha o drawer
                    // O drawer vai atualizar automaticamente
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Função auxiliar para criar os itens da lista
  Widget _buildDrawerItem({
    required IconData icon, 
    required String text, 
    required VoidCallback onTap, 
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]), // Ícone num tom de cinza escuro
      title: Text(text, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}