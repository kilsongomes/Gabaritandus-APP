// router.dart - ATUALIZAR
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import das telas existentes
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/info_screen.dart';

// 🆕 Import das novas telas de exames
import 'features/exams/screens/exam_list_screen.dart';
import 'features/exams/screens/exam_students_screen.dart';
import 'features/exams/controller/exam_controller.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/info':
        return MaterialPageRoute(builder: (_) => const InfoScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());


  

      // NOVAS ROTAS PARA EXAMES
      case '/exams':
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ExamController(),
            child: const ExamListScreen(),
          ),
        );

      case '/exam-students':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ExamController(),
            child: ExamStudentsScreen(
              examId: args["examId"],
              examName: args["examName"],
              groupId: args["groupId"],
            ),
          ),
        );

      // 🆕 (OPCIONAL) Rota para captura de gabarito
      case '/capture-answer-sheet':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text("Capturar Gabarito: ${args["studentName"]}")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Tela de captura de gabarito"),
                  Text("Aluno: ${args["studentName"]}"),
                  Text("Exame: ${args["examName"]}"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Implementar captura de imagem/QR Code
                    },
                    child: const Text("Capturar Gabarito"),
                  ),
                ],
              ),
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Rota não encontrada"))),
        );
    }
  }
}