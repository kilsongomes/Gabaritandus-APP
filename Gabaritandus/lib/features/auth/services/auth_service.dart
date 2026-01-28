import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://backhomologa.educandus.com.br/api";

  Future<String?> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      // Log de envio
      print("➡️ [AuthService] POST $url");
      print("Body enviado: {username: $username, password: $password}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      // Log de resposta
      print("⬅️ [AuthService] Status: ${response.statusCode}");
      print("⬅️ [AuthService] Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          if (data is Map && data["success"] == true) {
            final token = data["data"]["token"] ?? "";
            final refreshToken = data["data"]["refresh_token"] ?? "";
            final user = data["data"]["user"] ?? {};

            // 🚨 CORREÇÃO: Pegar as roles do campo correto "user_role"
            final userRoles = data["data"]["user_role"] ?? [];

            // Extrair apenas as informações das roles que precisamos
            final roles = userRoles.map<Map<String, dynamic>>((role) {
              return {
                "role_id": role["role_id"],
                "role_name": role["role_name"],
              };
            }).toList();

            // Salvar localmente
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString("jwt_token", token);
            await prefs.setString("refresh_token", refreshToken);
            await prefs.setString("user", jsonEncode(user));
            await prefs.setString("roles", jsonEncode(roles));

            print("✅ [AuthService] Login bem-sucedido. Token salvo.");
            print("👤 Usuário: $user");
            print("👥 Roles: $roles");

            // Log dos dados salvos
            print("✅ [AuthService] Dados salvos:");
            print("   Token: ${token.substring(0, 20)}...");
            print("   User: ${prefs.getString('user')}");
            print("   Roles: ${prefs.getString('roles')}");

            return token;
          } else {
            print(
              "❌ [AuthService] Login falhou: ${data["message"] ?? "Resposta inesperada"}",
            );
          }
        } catch (e) {
          print("❌ [AuthService] Erro ao decodificar JSON: $e");
        }
      } else {
        print("❌ [AuthService] Erro HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ [AuthService] Exceção no login: $e");
    }

    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
    await prefs.remove("refresh_token");
    await prefs.remove("user");
    await prefs.remove("roles");
    print("👋 [AuthService] Logout concluído, dados limpos.");
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }
}
