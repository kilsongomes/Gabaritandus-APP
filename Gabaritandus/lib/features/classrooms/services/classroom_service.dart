import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ClassroomService {
  static const String baseUrl = "https://backhomologa.educandus.com.br/api"; //mudar para produção depois (https://back.educandus.com.br/api)

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<List<Map<String, dynamic>>> getUserClassrooms() async {
    // 🆕 SOLUÇÃO TEMPORÁRIA: Ignorar SSL para desenvolvimento
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback = 
          ((X509Certificate cert, String host, int port) => true);

    try {
      final token = await _getToken();
      
      if (token == null) {
        throw Exception("Token não disponível");
      }

      final url = Uri.parse("$baseUrl/community/room_user/listRoomsByUser?page=1&page_size=28&start=2025-01-01&end=2025-12-31");

      print("➡️ [CommunityService] Buscando turmas do usuário...");
      
      final request = await httpClient.getUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $token');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print("⬅️ [CommunityService] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        
        if (data is Map && data["success"] == true) {
          final classrooms = List<Map<String, dynamic>>.from(data["data"] ?? []);
          print("✅ [CommunityService] ${classrooms.length} turmas encontradas");
          return classrooms;
        } else {
          throw Exception(data["message"] ?? "Erro ao buscar turmas");
        }
      } else {
        throw Exception("Erro HTTP ${response.statusCode}: $responseBody");
      }
    } catch (e) {
      print("❌ [CommunityService] Erro ao buscar turmas: $e");
      rethrow;
    } finally {
      httpClient.close();
    }
  }

  Future<Map<String, dynamic>> getClassroomDetails(int roomId) async {
    // 🆕 SOLUÇÃO TEMPORÁRIA: Ignorar SSL para desenvolvimento
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback = 
          ((X509Certificate cert, String host, int port) => true);

    try {
      final token = await _getToken();
      
      if (token == null) {
        throw Exception("Token não disponível");
      }

      final url = Uri.parse("$baseUrl/community/room/singleView/$roomId");

      print("➡️ [CommunityService] Buscando detalhes da turma $roomId...");
      
      final request = await httpClient.getUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $token');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print("⬅️ [CommunityService] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        
        if (data is Map && data["success"] == true) {
          final classroomDetails = Map<String, dynamic>.from(data["data"] ?? {});
          print("✅ [CommunityService] Detalhes da turma carregados");
          return classroomDetails;
        } else {
          throw Exception(data["message"] ?? "Erro ao buscar detalhes da turma");
        }
      } else {
        throw Exception("Erro HTTP ${response.statusCode}: $responseBody");
      }
    } catch (e) {
      print("❌ [CommunityService] Erro ao buscar detalhes da turma: $e");
      rethrow;
    } finally {
      httpClient.close();
    }
  }
}