import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gabaritandus/features/auth/controller/auth_controller.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Acesso Restrito"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Este aplicativo é exclusivo para Professores e Gestores.\n\n"
                "Seu perfil ainda possui acesso liberado.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await authController.logout();

                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                child: const Text("Voltar para o Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
