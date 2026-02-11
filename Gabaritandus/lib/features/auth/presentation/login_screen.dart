// login_screen.dart - ADICIONAR TRATAMENTO PARA DESMARCAR CHECKBOX
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
  bool _isFirstLoad = true;

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

    // Carrega as credenciais salvas apenas se saveInfo for true
    if (authController.saveInfo) {
      final savedCredentials = await authController.getSavedCredentials();

      if (savedCredentials['username'] != null) {
        usernameController.text = savedCredentials['username']!;
      }
      if (savedCredentials['password'] != null) {
        passwordController.text = savedCredentials['password']!;
      }
      
      print("🔍 [LoginScreen] Credenciais carregadas: ${savedCredentials['username']}");
    }
    
    _isFirstLoad = false;
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
                          autocorrect: false,
                          enableSuggestions: false,
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
                          obscureText: !auth.passwordVisible,
                          decoration: InputDecoration(
                            labelText: "Senha",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                                final newValue = value ?? false;
                                auth.setSaveInfo(newValue);
                                
                                // Se desmarcar o checkbox E não for primeira carga, limpar campos
                                if (!newValue && !_isFirstLoad) {
                                  setState(() {
                                    usernameController.clear();
                                    passwordController.clear();
                                  });
                                  print("🗑️ [LoginScreen] Checkbox desmarcado, campos limpos");
                                }
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
                                    print("🔄 [LoginScreen] Tentando login...");
                                    print("   Usuário: ${usernameController.text}");
                                    print("   Salvar info: ${auth.saveInfo}");
                                    
                                    final result = await auth.login(
                                      usernameController.text,
                                      passwordController.text,
                                    );

                                    if (!context.mounted) return;

                                    switch (result) {
                                      case LoginResult.success:
                                        print("✅ [LoginScreen] Login bem-sucedido, navegando para exames");
                                        Navigator.pushReplacementNamed(
                                          context,
                                          "/exams",
                                        );
                                        break;

                                      case LoginResult.blockedRole:
                                        print("🚫 [LoginScreen] Role bloqueada");
                                        Navigator.pushReplacementNamed(
                                          context,
                                          "/info",
                                        );
                                        break;

                                      case LoginResult.invalid:
                                        print("❌ [LoginScreen] Login inválido");
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