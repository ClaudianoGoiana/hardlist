import 'package:flutter/material.dart';
import '../screens/products_screen.dart'; // Importamos a tela de produtos para poder navegar até ela
import '../screens/categories_screen.dart'; // Importamos a tela de categorias para poder navegar até ela
import '../screens/expenses_screen.dart';
import '../screens/login_screen.dart';
import '../screens/history_screen.dart';
import '../screens/cloud_screen.dart';
import '../screens/lists_screen.dart';
import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';

// Widget do Menu Lateral
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Cabeçalho transformado em área de Login
          // Envolvemos em um InkWell para que ele seja "clicável" no futuro

       // Cabeçalho transformado em botão
       InkWell(
         onTap: () {
           // 1. Primeiro fechamos o menu lateral
           Navigator.pop(context); 
           // 2. Depois abrimos a tela de Login
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

          // Lista de opções do menu lateral (limpa e atualizada)
          _buildDrawerItem(
            icon: Icons.list_alt, 
            text: 'Listas', 
            onTap: () {
              Navigator.pop(context); // Fecha o menu
              Navigator.push( // Abre a tela de Listas
                context,
                MaterialPageRoute(builder: (context) => const ListsScreen()),
              );
            }
          ),
          // ... (dentro da ListView do app_drawer) ...
          _buildDrawerItem(
            icon: Icons.shopping_basket, 
            text: 'Produtos', 
            onTap: () {
              // 1. Fecha o menu lateral
              Navigator.pop(context); 
              // 2. Abre a tela de Produtos
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductsScreen()),
              );
            }
          ),

          _buildDrawerItem(
            icon: Icons.format_list_bulleted, 
            text: 'Categorias', 
            onTap: () {
              // 1. Fecha o menu lateral
              Navigator.pop(context); 
              // 2. Navega para a tela de Categorias
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoriesScreen()),
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
          _buildDrawerItem(icon: Icons.mark_email_unread, text: 'Listas recebidas', onTap: () {}),
          _buildDrawerItem(
            icon: Icons.cloud, 
            text: 'HardList Cloud', 
            onTap: () {
              Navigator.pop(context); // Fecha o menu lateral
              Navigator.push( 
                context,
                MaterialPageRoute(
                  // Aqui nós passamos as variáveis dinâmicas! 
                  // Mude os nomes aqui para testar se quiser.
                  builder: (context) => const CloudScreen(
                    nomeUsuario: 'João da Silva', 
                    emailUsuario: 'joao@email.com',
                  ),
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
        ],
      ),
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