// exam_service.dart - SIMPLIFICAR
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class ExamService {
  static const String baseUrl = "https://adrbackend.educandus.com.br";

  Future<int?> _getGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    final groupId = prefs.getInt("group_id");

    print("🔍 [ExamService] Group ID do SharedPreferences: $groupId");

    if (groupId == null) {
      print("❌ [ExamService] Group ID não encontrado. O usuário fez login?");
    }

    return groupId;
  }

  Future<String?> _getGroupToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("group_token");

    if (token == null) {
      print("⚠️ [ExamService] Token do grupo não encontrado");
    } else {
      print(
        "🔐 [ExamService] Token do grupo encontrado (${token.length} chars)",
      );
    }

    return token;
  }

  Future<List<Map<String, dynamic>>> getTeacherExams() async {
    final groupId = await _getGroupId();

    if (groupId == null) {
      throw Exception("Group ID não disponível. Faça login novamente.");
    }

    return await getExamsByGroupId(groupId);
  }

  Future<List<Map<String, dynamic>>> getExamsByGroupId(int groupId) async {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final token = await _getGroupToken();

      if (token == null) {
        throw Exception("Token de autenticação não disponível");
      }

      final url = Uri.parse(
        "$baseUrl/exam/list-exams-by-group-id/$groupId?page=0&pageSize=100&sortBy=name&sortOrder=desc",
      );

      print("➡️ [ExamService] Buscando exames para group_id: $groupId");
      print("URL: $url");
      print("Token: ${token.substring(0, min(20, token.length))}...");

      final request = await httpClient.getUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print("⬅️ [ExamService] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        if (data is Map && data["message"] == "Exams fetched successfully") {
          final exams = List<Map<String, dynamic>>.from(
            data["data"]["exams"] ?? [],
          );
          print("✅ [ExamService] ${exams.length} exames encontrados");

          if (exams.isNotEmpty) {
            print("📝 Primeiros 3 exames:");
            for (var i = 0; i < exams.length && i < 3; i++) {
              final exam = exams[i];
              print("   ${i + 1}. ${exam["name"]} - ${exam["status"]}");
            }
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

  Future<Map<String, dynamic>> getExamDetails(String examId) async {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final token = await _getGroupToken();

      if (token == null) {
        throw Exception("Token não disponível");
      }

      // CORREÇÃO: Usar o endpoint correto que você me mostrou
      final url = Uri.parse(
        "$baseUrl/user/list-users-by-exam-schedules/$examId?pageSize=100&groupId=11&page=0&regionId=14&schoolId=7558",
      );

      print("➡️ [ExamService] Buscando detalhes do exame: $examId");
      print("URL: $url");

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
          print("   Número de usuários: ${data["data"]["users"].length}");
          print("   Nome do exame: ${data["data"]["exam"]["name"]}");
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
}
