import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carregar informações salvas quando a tela inicia
    _loadSavedInfo();
  }

  // Carregar informações salvas
  void _loadSavedInfo() async {
    final authController = Provider.of<AuthController>(context, listen: false);

    // Carrega a preferência de salvar informações
    await authController.loadSavedLoginInfo();

    // Carrega as credenciais salvas
    final savedCredentials = await authController.getSavedCredentials();

    if (savedCredentials['username'] != null) {
      usernameController.text = savedCredentials['username']!;
    }
    if (savedCredentials['password'] != null) {
      passwordController.text = savedCredentials['password']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B4D8),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                "Gabaritandus",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // Card branco
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.4 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Consumer<AuthController>(
                  builder: (context, auth, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campo Username
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: "Usuário",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Campo Senha com olho
                        TextField(
                          controller: passwordController,
                          obscureText: !auth
                              .passwordVisible, // Controlado pelo controller
                          decoration: InputDecoration(
                            labelText: "Senha",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // Ícone de olho para mostrar/esconder senha
                            suffixIcon: IconButton(
                              icon: Icon(
                                auth.passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                auth.togglePasswordVisibility();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Checkbox funcionando
                        Row(
                          children: [
                            Checkbox(
                              value: auth.saveInfo,
                              onChanged: (value) {
                                auth.setSaveInfo(value ?? false);
                              },
                            ),
                            const Text("Salvar informações"),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Mensagem de erro
                        if (auth.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              auth.error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Botão Entrar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B5BFF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: auth.loading
                                ? null
                                : () async {
                                    final result = await auth.login(
                                      usernameController.text,
                                      passwordController.text,
                                    );

                                    if (!context.mounted) return;

                                    switch (result) {
                                      case LoginResult.success:
                                        Navigator.pushReplacementNamed(
                                          context,
                                          "/classrooms",
                                        );
                                        break;

                                      case LoginResult.blockedRole:
                                        Navigator.pushReplacementNamed(
                                          context,
                                          "/info",
                                        );
                                        break;

                                      case LoginResult.invalid:
              
                                        break;
                                    }
                                  },
                            child: auth.loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Entrar",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Esqueceu a senha
                        Column(
                          children: [
                            const Text("Esqueceu a senha?"),
                            TextButton(
                              onPressed: () {
                                // ação de recuperação
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                              child: const Text("Recuperar"),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
