import 'package:flutter/material.dart';
import 'register_screen.dart'; // <-- Adicione esta linha!


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco para dar um ar limpo
      
      // Barra superior transparente apenas com o botão de voltar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove a sombra
        // Cor do botão de voltar (o Flutter coloca o botão sozinho)
        foregroundColor: const Color(0xFF1565C0), 
      ),
      
      // O SingleChildScrollView evita que o teclado cubra os campos dando erro
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0), // Espaço nas bordas
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 1. Logotipo e Título ---
              // Usamos um ícone de carrinho para representar o HardList
              const Icon(Icons.shopping_cart_checkout, size: 80, color: Color(0xFF1565C0)),
              const SizedBox(height: 16),
              const Text(
                'Bem-vindo ao HardList',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF1565C0)
                ),
              ),
              const SizedBox(height: 32),

              // --- 2. Campo de E-mail ---
              TextField(
                decoration: InputDecoration(
                  labelText: 'E-mail', // Texto que flutua
                  prefixIcon: const Icon(Icons.email), // Ícone dentro do campo
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12) // Borda arredondada
                  ),
                ),
                keyboardType: TextInputType.emailAddress, // Mostra o teclado com o "@"
              ),
              const SizedBox(height: 16),

              // --- 3. Campo de Senha ---
              TextField(
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                ),
                obscureText: true, // MÁGICA: Esconde o texto digitado (***)
              ),
              const SizedBox(height: 8),

              // --- 4. Botão Esqueci a Senha ---
              Align(
                alignment: Alignment.centerRight, // Joga o botão para a direita
                child: TextButton(
                  onPressed: () {
                    print("Clicou em Esqueci a senha");
                  },
                  child: const Text('Esqueceu a senha?'),
                ),
              ),
              const SizedBox(height: 24),

              // --- 5. Botão de ENTRAR ---
              SizedBox(
                width: double.infinity, // Faz o botão ocupar a largura toda
                height: 50, // Altura do botão
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2), // Nosso azul vibrante
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    print("Fazer login...");
                    // No futuro, aqui você valida a senha.
                    // Por enquanto, vamos fazer ele fechar a tela e voltar para a Home
                    Navigator.pop(context); 
                  },
                  child: const Text(
                    'ENTRAR', 
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 6. Opção de Criar Conta ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Centraliza tudo
                children: [
                  const Text('Não tem uma conta?'),
                  TextButton(
                 onPressed: () {
                   // Navega para a Tela de Cadastro!
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const RegisterScreen()),
                   );
                 },
                 child: const Text('Cadastre-se', style: TextStyle(fontWeight: FontWeight.bold)),
               ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}