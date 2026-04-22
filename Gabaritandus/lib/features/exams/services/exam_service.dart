// exam_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config.dart'; // 🔥 Importa a configuração centralizada

class ExamService {
  Future<int?> _getGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    final groupId = prefs.getInt("group_id");

    print("🔍 [ExamService] Group ID do SharedPreferences: $groupId");

    if (groupId == null) {
      print("❌ [ExamService] Group ID não encontrado. O usuário fez login?");
    }

    return groupId;
  }

  Future<int?> _getRegionId() async {
    final prefs = await SharedPreferences.getInstance();
    final regionId = prefs.getInt("region_id");
    print("🔍 [ExamService] Region ID: $regionId");
    return regionId;
  }

  Future<int?> _getSchoolId() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolId = prefs.getInt("school_id");
    print("🔍 [ExamService] School ID: $schoolId");
    return schoolId;
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
    try {
      final token = await _getGroupToken();

      if (token == null) {
        throw Exception("Token de autenticação não disponível");
      }

      // 🔥 Usa a URL do config.dart
      final url = Uri.parse(
        "$mainApiUrl/exam/list-exams-by-group-id/$groupId?page=0&pageSize=100&sortBy=name&sortOrder=desc",
      );

      print("➡️ [ExamService] Buscando exames para group_id: $groupId");
      print("URL: $url");
      print(
        "Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...",
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("⬅️ [ExamService] Status: ${response.statusCode}");

      final responseBody = response.body;

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
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getExamDetails(String examId) async {
    try {
      final token = await _getGroupToken();
      final groupId = await _getGroupId();
      final regionId = await _getRegionId();
      final schoolId = await _getSchoolId();

      if (token == null) {
        throw Exception("Token não disponível");
      }

      if (groupId == null) {
        throw Exception("Group ID não disponível");
      }

      if (regionId == null) {
        print("⚠️ [ExamService] Region ID não disponível, usando fallback 14");
      }

      if (schoolId == null) {
        print(
          "⚠️ [ExamService] School ID não disponível, usando fallback 7558",
        );
      }

      // 🔥 Usa a URL do config.dart
      final url = Uri.parse(
        "$mainApiUrl/user/list-users-by-exam-schedules/$examId?pageSize=100&groupId=$groupId&page=0&regionId=${regionId ?? 14}&schoolId=${schoolId ?? 7558}",
      );

      print("➡️ [ExamService] Buscando detalhes do exame: $examId");
      print("URL: $url");
      print("Group ID usado: $groupId");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("⬅️ [ExamService] Status: ${response.statusCode}");

      final responseBody = response.body;

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
    }
  }
}
