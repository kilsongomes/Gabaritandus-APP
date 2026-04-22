import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String loginUrl = "https://back.educandus.com.br/api/login";

  Future<String?> login(String username, String password) async {
    try {
      print("➡️ POST $loginUrl");

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      print("⬅️ Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["success"] == true) {
          final data = json["data"];

          // 🔐 TOKEN
          final token = data["token"];

          // 💾 SALVAR TUDO DE UMA VEZ
          await _saveUserData(data, token);

          print("✅ Login completo (SEM /user/me)");

          return data["user"]["id"].toString();
        }
      }

      print("❌ Login falhou");
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
    print("👤 $userName");
    print("🎭 $roleName");
    print("🏢 $groupName");
    print("🏫 $schoolName");

    // 🔐 TOKEN
    await prefs.setString("token", token);
    await prefs.setString("group_token", token);

    // 👤 USER
    await prefs.setString("user", jsonEncode(data));
    await prefs.setString("user_name", userName);
    await prefs.setString("user_photo", userPhoto);
    await prefs.setString("user_role", roleName);

    // 🏢 GROUP
    await prefs.setString("group_name", groupName);
    await prefs.setInt("group_id", groupId);

    // 🗺️ REGION
    await prefs.setString("region_name", regionName);
    await prefs.setInt("region_id", regionId);

    // 🏫 SCHOOL
    await prefs.setString("school_name", schoolName);
    await prefs.setInt("school_id", schoolId);

    print("✅ Dados salvos com sucesso");
  }

  // 🔥 Método genérico para chamadas autenticadas
  Future<http.Response?> get(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        print("❌ Token não encontrado");
        return null;
      }

      return await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
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
