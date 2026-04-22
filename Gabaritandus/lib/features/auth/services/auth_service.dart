// auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config.dart';

class AuthService {
  Future<String?> login(String username, String password) async {
    try {
      final url = Uri.parse(loginApiUrl);
      print("➡️ POST $url");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      print("⬅️ Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json["success"] == true) {
          final data = json["data"];
          final token = data["token"];
          await _saveUserData(data, token);
          print("✅ Login completo");
          return data["user"]["id"].toString();
        }
      }
      return null;
    } catch (e) {
      print("❌ Erro login: $e");
      return null;
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> data, String token) async {
    final prefs = await SharedPreferences.getInstance();

    final user = data["user"];
    final roles = data["user_role"] ?? [];
    final role = roles.isNotEmpty ? roles[0] : {};

    final userName = user["name"] ?? user["username"] ?? "";
    final userPhoto = user["photo"] ?? "";
    final roleName = role["role_name"] ?? "";
    final groupName = role["group_name"] ?? "";
    final regionName = role["region_name"] ?? "";
    final schoolName = role["school_name"] ?? "";
    final groupId = role["group_id"] ?? 0;
    final regionId = role["region_id"] ?? 0;
    final schoolId = role["school_id"] ?? 0;

    print("💾 Salvando dados:");
    print("👤 Usuário: $userName");
    print("🎭 Role: $roleName");
    print("🏢 Group ID: $groupId");

    // Tokens
    await prefs.setString("token", token);
    await prefs.setString("group_token", token);
    await prefs.setString("auth_token", token);

    // Dados do usuário
    await prefs.setString("user", jsonEncode(data));
    await prefs.setString("user_name", userName);
    await prefs.setString("user_photo", userPhoto);
    await prefs.setString("user_role", roleName);

    // Group
    await prefs.setString("group_name", groupName);
    await prefs.setInt("group_id", groupId);

    // Region
    await prefs.setString("region_name", regionName);
    await prefs.setInt("region_id", regionId);

    // School
    await prefs.setString("school_name", schoolName);
    await prefs.setInt("school_id", schoolId);

    print("✅ Dados salvos com sucesso");
  }

  // Método genérico para chamadas GET autenticadas
  Future<http.Response?> get(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        print("❌ Token não encontrado");
        return null;
      }

      // Se a URL for relativa, completa com o proxy
      final fullUrl = url.startsWith("http")
          ? Uri.parse(url)
          : Uri.parse("$mainApiUrl$url");

      print("➡️ GET ${fullUrl}");
      print(
        "   Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...",
      );

      final response = await http.get(
        fullUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("⬅️ GET Status: ${response.statusCode}");
      return response;
    } catch (e) {
      print("❌ Erro GET: $e");
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("👋 Logout completo");
  }
}
