import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/info_screen.dart';
import 'features/exams/screens/exam_list_screen.dart';
import 'features/exams/screens/exam_students_screen.dart';
import 'features/exams/controller/exam_controller.dart';
import 'features/answer_sheet/screens/capture_answer_sheet_screen.dart';

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
              examGrade: args["examGrade"] ?? "Ano não informado",
              disciplineName: args["disciplineName"] ?? "Disciplina não informada",
              numberOfQuestions: args["numberOfQuestions"] ?? 10,
            ),
          ),
        );

      // Rota para captura de gabarito
      case '/capture-answer-sheet':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CaptureAnswerSheetScreen(
            studentName: args["studentName"],
            examName: args["examName"],
            studentId: args["studentId"],
            examId: args["examId"],
            examGrade: args["examGrade"] ?? "Ano não informado",
            numberOfQuestions: args["numberOfQuestions"] ?? 10,
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
