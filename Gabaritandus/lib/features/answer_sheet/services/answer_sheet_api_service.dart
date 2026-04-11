import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../controller/api_config.dart';

class AnswerSheetApiService {
  static final String baseUrl = ApiConfig.baseUrl;

  Future<List<String?>> processAnswerSheet(
    dynamic imageFile,
    int numberOfQuestions,
  ) async {
    try {
      print("📤 [AnswerSheetApiService] Enviando imagem para API...");
      print("   Número de questões: $numberOfQuestions");
      print("   Base URL: $baseUrl");

      // 🔥 Validação importante
      if (kIsWeb && imageFile is! Uint8List) {
        throw Exception("Na WEB, imageFile deve ser Uint8List");
      }

      if (!kIsWeb && imageFile == null) {
        throw Exception("Imagem inválida");
      }

      // Escolher endpoint
      final endpoint = numberOfQuestions == 20
          ? "/processar_20_questoes"
          : "/processar_10_questoes";

      final uri = Uri.parse("$baseUrl$endpoint");

      print("   URL: $uri");

      final request = http.MultipartRequest("POST", uri);

      request.headers.addAll({"Accept": "application/json"});

      // 🔥 PARTE MAIS IMPORTANTE
      if (kIsWeb) {
        print("🌐 Upload via WEB (bytes)");

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageFile,
            filename: 'answer_sheet.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        print("📱 Upload via MOBILE (path)");

        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );
      }

      print("   Enviando requisição...");

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      print("⬅️ Status Code: ${response.statusCode}");
      print("⬅️ Response Body: $responseBody");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        if (data["success"] == true) {
          final respostasRaw = data["respostas"] as List;
          final totalQuestoes = data["questoes"] as int;

          List<String?> extractedAnswers = List<String?>.filled(
            totalQuestoes,
            null,
          );

          for (var item in respostasRaw) {
            final numero = item["numero"] as int;
            final resposta = item["resposta"] as String?;
            final respondida = item["respondida"] as bool;

            if (respondida && resposta != null && resposta.isNotEmpty) {
              final index = numero - 1;
              if (index < extractedAnswers.length) {
                extractedAnswers[index] = resposta;
              }
            }
          }

          print("✅ Processamento concluído");
          print(
            "   Total respondidas: ${extractedAnswers.where((a) => a != null).length}",
          );

          return extractedAnswers;
        } else {
          throw Exception(data["message"] ?? "Erro ao processar imagem");
        }
      } else {
        throw Exception("Erro HTTP ${response.statusCode}: $responseBody");
      }
    } catch (e, stack) {
      print("❌ [AnswerSheetApiService] Erro: $e");
      print("📍 Stack: $stack");
      rethrow;
    }
  }

  Future<bool> testConnection() async {
    try {
      print("🔌 Testando conexão...");

      final response = await http.get(Uri.parse("$baseUrl/"));

      print("Status: ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Erro de conexão: $e");
      return false;
    }
  }
}
