import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ExamService {
  static const String baseUrl = "https://adrbackend.educandus.com.br";

  Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("jwt_token");
  print("🔐 [ExamService] Token recuperado do SharedPreferences: ${token != null ? "SIM" : "NÃO"}");
  if (token != null) {
    print("   Token (primeiros 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...");
  }
  return token;
}

  // Método para obter o group_id do professor (a partir das turmas)
  Future<int?> getTeacherGroupId() async {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback = 
          ((X509Certificate cert, String host, int port) => true);
    
    try {
      final token = await _getToken();
      
      if (token == null) {
        print("❌ [ExamService] Token não encontrado no SharedPreferences");
        return null;
      }
      
      print("🔑 [ExamService] Token encontrado, buscando turmas...");
      
      final url = Uri.parse("https://backhomologa.educandus.com.br/api/community/room_user/listRoomsByUser?page=1&page_size=10");
      
      print("➡️ [ExamService] GET $url");
      
      final request = await httpClient.getUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $token');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print("⬅️ [ExamService] Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        print("📄 [ExamService] Resposta: ${responseBody.length} caracteres");
        final data = jsonDecode(responseBody);
        
        if (data is Map && data["success"] == true) {
          print("✅ [ExamService] Sucesso ao buscar turmas");
          
          // Verificar estrutura da resposta
          print("📋 [ExamService] Estrutura da resposta: ${data.keys}");
          
          if (data["data"] != null) {
            print("📦 [ExamService] Dados encontrados: ${data["data"].keys}");
            
            final classrooms = List<Map<String, dynamic>>.from(data["data"]["classrooms"] ?? []);
            print("🏫 [ExamService] ${classrooms.length} turmas encontradas");
            
            if (classrooms.isNotEmpty) {
              // Log detalhado das turmas
              print("📊 [ExamService] Detalhes das turmas:");
              for (var i = 0; i < classrooms.length && i < 5; i++) {
                final classroom = classrooms[i];
                print("   ${i + 1}. ${classroom["name"]} - group_id: ${classroom["group_id"]}");
              }
              
              final groupId = classrooms.first["group_id"];
              if (groupId != null) {
                print("✅ [ExamService] Group ID selecionado: $groupId");
                return groupId;
              } else {
                print("⚠️ [ExamService] Primeira turma não tem group_id");
              }
            } else {
              print("⚠️ [ExamService] Nenhuma turma encontrada na resposta");
            }
          } else {
            print("⚠️ [ExamService] Campo 'data' não encontrado na resposta");
          }
        } else {
          print("❌ [ExamService] Resposta não é sucesso: ${data["message"]}");
        }
      } else {
        print("❌ [ExamService] Erro HTTP ${response.statusCode}");
        print("📄 Resposta: $responseBody");
      }
      
      print("⚠️ [ExamService] Retornando null - não encontrou group_id");
      return null;
    } catch (e) {
      print("❌ [ExamService] Exceção em getTeacherGroupId: $e");
      print("Stack trace: ${e.toString()}");
      return null;
    } finally {
      httpClient.close();
    }
  }

  // Buscar detalhes de um exame específico
  Future<Map<String, dynamic>> getExamDetails(String examId) async {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception("Token não disponível");
      }

      // 🆕 ENDPOINT PARA DETALHES DO EXAME (baseado na resposta que você mostrou)
      final url = Uri.parse("$baseUrl/exam/$examId/users");

      print("➡️ [ExamService] Buscando detalhes do exame: $examId");

      final request = await httpClient.getUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print("⬅️ [ExamService] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        if (data is Map && data["message"] == "Users successfully listed") {
          print("✅ [ExamService] Detalhes do exame carregados");
          return data["data"];
        } else {
          throw Exception(
            data["message"] ?? "Erro ao buscar detalhes do exame",
          );
        }
      } else {
        throw Exception("Erro HTTP ${response.statusCode}: $responseBody");
      }
    } catch (e) {
      print("❌ [ExamService] Erro ao buscar detalhes do exame: $e");
      rethrow;
    } finally {
      httpClient.close();
    }
  }

  // Buscar exames por group_id (opcional)
  Future<List<Map<String, dynamic>>> getExamsByGroupId(int groupId) async {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception("Token não disponível");
      }

      // ENDPOINT CORRETO PARA EXAMES
      final url = Uri.parse(
      "$baseUrl/exam/list-exams-by-group-id/$groupId?page=0&pageSize=100&sortBy=name&sortOrder=desc",
    );

      print("➡️ [ExamService] Buscando exames para group_id: $groupId");
      print("URL: $url");

      final request = await httpClient.getUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print("⬅️ [ExamService] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        if (data is Map && data["message"] == "Exams fetched successfully") {
          // 🆕 Acessar corretamente a lista de exames
          final exams = List<Map<String, dynamic>>.from(
            data["data"]["exams"] ?? [],
          );
          print("✅ [ExamService] ${exams.length} exames encontrados");

          // 🆕 Log para debug
          if (exams.isNotEmpty) {
            print("📝 Primeiro exame: ${exams.first["name"]}");
          }

          return exams;
        } else {
          print("❌ [ExamService] Resposta inesperada: ${data["message"]}");
          throw Exception(data["message"] ?? "Erro ao buscar exames");
        }
      } else {
        print(
          "❌ [ExamService] Erro HTTP ${response.statusCode}: $responseBody",
        );
        throw Exception("Erro HTTP ${response.statusCode}: $responseBody");
      }
    } catch (e) {
      print("❌ [ExamService] Erro ao buscar exames: $e");
      print("Stack trace: ${e.toString()}");
      rethrow;
    } finally {
      httpClient.close();
    }
  }
}
