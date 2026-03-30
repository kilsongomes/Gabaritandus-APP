import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/controller/auth_controller.dart';
import 'router.dart';

class GabaritandusApp extends StatelessWidget {
  const GabaritandusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: MaterialApp(
        title: 'Gabaritandus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xfff0f4fb), 
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xff004aad),
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: '/login',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
