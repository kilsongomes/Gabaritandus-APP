import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import das telas
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/classrooms/screens/classoom_list_screen.dart';
import 'features/classrooms/screens/student_list_screen.dart';
import '/answer_sheets/screens/capture_screen.dart';
import 'features/home/presentation/info_screen.dart';
import 'features/classrooms/controllers/classroom_controller.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/info':
        return MaterialPageRoute(builder: (_) => const InfoScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/questions':
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ClassroomController(),
            child: const OpenQuestionScreen(),
          ),
        );
      case '/student-list':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ClassroomController(),
            child: StudentListScreen(
              turma: args["turma"],
              escola: args["escola"],
              roomId: args["roomId"], // 🆕 Passando o roomId
            ),
          ),
        );
      case '/capture':
        final args = settings.arguments as Map<String, dynamic>;
  return MaterialPageRoute(
    builder: (_) => CaptureScreen(
      studentId: args["studentId"],
      studentName: args["studentName"],
      classroomId: args["classroomId"],
      classroomName: args["classroomName"],
      discipline: args["discipline"],
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
