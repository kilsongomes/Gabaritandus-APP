import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String loginUrl = "https://loginbackend.educandus.com.br/auth/login";
  static const String userInfoUrl = "https://adrapi.educandus.com.br/user/me";
  
  // Armazenar cookies entre requisições
  final HttpClient _httpClient = HttpClient()
    ..badCertificateCallback = 
        ((X509Certificate cert, String host, int port) => true);
  
  // Gerenciador de cookies
  final CookieManager _cookieManager = CookieManager();
  
  Future<String?> login(String username, String password) async {
    try {
      // 1. Fazer login
      print("➡️ [AuthService] POST $loginUrl");
      print("Body enviado: {username: $username, password: $password}");
      
      final loginRequest = await _httpClient.postUrl(Uri.parse(loginUrl));
      loginRequest.headers.set('Content-Type', 'application/json');
      loginRequest.write(jsonEncode({
        "username": username,
        "password": password,
      }));
      
      final loginResponse = await loginRequest.close();
      final loginResponseBody = await loginResponse.transform(utf8.decoder).join();
      
      print("⬅️ [AuthService] Status: ${loginResponse.statusCode}");
      print("⬅️ [AuthService] Body: $loginResponseBody");
      
      if (loginResponse.statusCode == 200) {
        final loginData = jsonDecode(loginResponseBody);
        
        if (loginData["success"] == true) {
          final userData = loginData["data"];
          final userId = userData["user_id"];
          
          print("✅ [AuthService] Login bem-sucedido. User ID: $userId");
          
          // Salvar cookies da resposta
          _saveCookies(loginResponse);
          
          // 2. Buscar informações completas do usuário
          final userInfo = await _getUserInfo();
          
          if (userInfo != null) {
            // Salvar todos os dados
            await _saveUserData(userInfo);
            return userId.toString();
          } else {
            print("❌ [AuthService] Não foi possível obter informações do usuário");
            return null;
          }
        }
      }
      
      print("❌ [AuthService] Login falhou");
      return null;
    } catch (e) {
      print("❌ [AuthService] Exceção no login: $e");
      return null;
    }
  }
  
  // Método para salvar cookies da resposta
  void _saveCookies(HttpClientResponse response) {
    try {
      final cookies = response.cookies;
      if (cookies.isNotEmpty) {
        print("🍪 [AuthService] Cookies recebidos:");
        for (var cookie in cookies) {
          print("   - ${cookie.name}=${cookie.value}");
          _cookieManager.saveCookie(cookie);
        }
      }
    } catch (e) {
      print("⚠️ [AuthService] Erro ao salvar cookies: $e");
    }
  }
  
  // Método para adicionar cookies à requisição
  void _addCookiesToRequest(HttpClientRequest request) {
    try {
      final cookies = _cookieManager.getCookiesForUrl(request.uri);
      if (cookies.isNotEmpty) {
        final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');
        request.headers.set('Cookie', cookieHeader);
        print("🍪 [AuthService] Cookies enviados: $cookieHeader");
      }
    } catch (e) {
      print("⚠️ [AuthService] Erro ao adicionar cookies: $e");
    }
  }
  
  Future<Map<String, dynamic>?> _getUserInfo() async {
    try {
      print("➡️ [AuthService] GET $userInfoUrl");
      
      final request = await _httpClient.getUrl(Uri.parse(userInfoUrl));
      request.headers.set('Content-Type', 'application/json');
      
      // Adicionar cookies à requisição
      _addCookiesToRequest(request);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print("⬅️ [AuthService] Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        print("✅ [AuthService] Informações do usuário obtidas");
        return data;
      } else {
        print("❌ [AuthService] Erro ao obter informações: ${response.statusCode}");
        print("📄 Resposta: $responseBody");
        return null;
      }
    } catch (e) {
      print("❌ [AuthService] Erro em _getUserInfo: $e");
      return null;
    }
  }
  
  Future<void> _saveUserData(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // Extrair dados importantes
      final user = userInfo["user"] ?? {};
      final role = userInfo["role"] ?? {};
      final group = userInfo["group"] ?? {};
      final region = userInfo["region"] ?? {};
      final school = userInfo["school"] ?? {};
      final rooms = userInfo["rooms"] ?? [];
      
      final userName = user["name"] ?? user["username"] ?? "";
      final userRole = role["name"] ?? "Professor";
      final userPhoto = user["photo"] ?? "";
      final groupId = group["id"] ?? 0;
      final groupName = group["name"] ?? "";
      final groupToken = group["token"] ?? "";
      final regionId = region["id"] ?? 0;
      final schoolId = school["id"] ?? 0;
      
      print("💾 [AuthService] Salvando dados do usuário:");
      print("   👤 Nome: $userName");
      print("   🎭 Role: $userRole");
      print("   🏢 Grupo: $groupName (ID: $groupId)");
      print("   🔐 Token do grupo: ${groupToken.isNotEmpty ? "SIM" : "NÃO"}");
      print("   🏫 Escola: ${school["name"]}");
      print("   🏫 Escola: ${school["name"]} (ID: $schoolId)"); // 🔥 Adicionado ID
      print("   🗺️ Região: ${region["name"]} (ID: $regionId)");
      print("   📚 Turmas: ${rooms.length}");
      
      // Salvar no SharedPreferences
      await prefs.setString("user", jsonEncode(userInfo));
      await prefs.setString("user_name", userName);
      await prefs.setString("user_role", userRole);
      await prefs.setString("user_photo", userPhoto);
      await prefs.setInt("group_id", groupId);
      await prefs.setString("group_name", groupName);
      await prefs.setString("group_token", groupToken);
      await prefs.setString("region_name", region["name"] ?? "");
      await prefs.setInt("region_id", regionId);
      await prefs.setString("school_name", school["name"] ?? "");
      await prefs.setInt("school_id", schoolId);
      
      print("✅ [AuthService] Dados salvos com sucesso");
      
    } catch (e) {
      print("❌ [AuthService] Erro ao salvar dados: $e");
    }
  }
  
  Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  
  print("👋 [AuthService] Iniciando logout...");
  
  // 🟢 ANTES: Verificar o que temos salvo
  final savedUsername = prefs.getString('saved_username');
  final savedPassword = prefs.getString('saved_password');
  final saveInfo = prefs.getBool('save_info');
  
  print("   📊 Estado ANTES do logout:");
  print("     saved_username: $savedUsername");
  print("     saved_password: ${savedPassword != null ? "SALVO" : "NÃO SALVO"}");
  print("     save_info: $saveInfo");
  
  // 🟢 LIMPAR APENAS DADOS DA SESSÃO (NÃO CREDENCIAIS)
  // Remover dados do usuário
  await prefs.remove("user");
  await prefs.remove("user_name");
  await prefs.remove("user_role");
  await prefs.remove("user_photo");
  await prefs.remove("group_id");
  await prefs.remove("group_token");
  await prefs.remove("group_name");
  await prefs.remove("region_name");
  await prefs.remove("school_name");
  
  // 🟢 NÃO REMOVER (manter credenciais de login):
  // - saved_username
  // - saved_password
  // - save_info
  
  // 🟢 Também limpar cookies da sessão HTTP
  _cookieManager.clearCookies();
  
  // 🟢 DEPOIS: Verificar o que ficou
  final savedUsernameAfter = prefs.getString('saved_username');
  final savedPasswordAfter = prefs.getString('saved_password');
  final saveInfoAfter = prefs.getBool('save_info');
  
  print("   📊 Estado DEPOIS do logout:");
  print("     saved_username: $savedUsernameAfter");
  print("     saved_password: ${savedPasswordAfter != null ? "SALVO" : "NÃO SALVO"}");
  print("     save_info: $saveInfoAfter");
  
  print("✅ [AuthService] Logout concluído. Dados da sessão limpos, credenciais mantidas.");
}
  
  Future<int?> getGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("group_id");
  }
  
  Future<String?> getGroupToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("group_token");
  }
}

// Classe auxiliar para gerenciar cookies
class CookieManager {
  final Map<String, Cookie> _cookies = {};
  
  void saveCookie(Cookie cookie) {
    _cookies[cookie.name] = cookie;
  }
  
  List<Cookie> getCookiesForUrl(Uri uri) {
    return _cookies.values.toList();
  }
  
  void clearCookies() {
    _cookies.clear();
  }
}