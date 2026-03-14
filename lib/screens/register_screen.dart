import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // Barra superior com o botão de voltar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1565C0), 
        title: const Text('Nova Conta', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 1. Ícone de Cadastro ---
              const Icon(Icons.person_add_alt_1, size: 80, color: Color(0xFF1565C0)),
              const SizedBox(height: 16),
              const Text(
                'Crie seu acesso',
                style: TextStyle(fontSize: 22, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // --- 2. Campo de Nome ---
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: const Icon(Icons.person), // Ícone de pessoa
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.name, // Teclado otimizado para nomes (inicia com letra maiúscula)
              ),
              const SizedBox(height: 16),

              // --- 3. Campo de E-mail ---
              TextField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // --- 4. Campo de Senha ---
              TextField(
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true, // Esconde a senha
              ),
              const SizedBox(height: 16),

              // --- 5. Campo de Confirmar Senha ---
              TextField(
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha',
                  prefixIcon: const Icon(Icons.lock_outline), // Ícone de cadeado vazado para diferenciar
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),

              // --- 6. Botão de CRIAR CONTA ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2), // Azul vibrante
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    print("Processando o cadastro...");
                    // Por enquanto, apenas volta para a tela de login
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'CRIAR CONTA', 
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 7. Opção de Voltar para o Login ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Já tem uma conta?'),
                  TextButton(
                    onPressed: () {
                      // Se ele já tem conta, apenas fechamos esta tela (voltamos pro login)
                      Navigator.pop(context); 
                    },
                    child: const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold)),
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