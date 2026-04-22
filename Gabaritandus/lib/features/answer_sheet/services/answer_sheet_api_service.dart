// answer_sheet_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../../config.dart'; // 🔥 Importa a configuração centralizada

class AnswerSheetApiService {
  Future<List<String?>> processAnswerSheet(
    dynamic imageFile,
    int numberOfQuestions,
  ) async {
    try {
      print("📤 [AnswerSheetApiService] Enviando imagem para API...");
      print("   Número de questões: $numberOfQuestions");
      print("   Base URL: $omrApiUrl"); // 🔥 Usa a URL do config.dart

      // 🔥 Validação importante
      if (kIsWeb && imageFile is! Uint8List) {
        throw Exception("Na WEB, imageFile deve ser Uint8List");
      }

      if (!kIsWeb && imageFile == null) {
        throw Exception("Imagem inválida");
      }

      // Escolher endpoint baseado no número de questões
      final endpoint = numberOfQuestions == 20
          ? "/processar_20_questoes"
          : "/processar_10_questoes";

      print(
        "   📍 Usando endpoint: $endpoint (baseado em $numberOfQuestions questões)",
      );

      // 🔥 Usa a URL do config.dart
      final uri = Uri.parse("$omrApiUrl$endpoint");

      print("   URL: $uri");

      final request = http.MultipartRequest("POST", uri);

      request.headers.addAll({"Accept": "application/json"});

      // 🔥 Parte mais importante - anexar a imagem
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageFile,
            filename: 'answer_sheet.jpg',
            contentType: http.MediaType('image', 'jpeg'),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
            contentType: http.MediaType('image', 'jpeg'),
          ),
        );
      }

      print("   Enviando requisição...");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("⬅️ Status Code: ${response.statusCode}");
      print(
        "⬅️ Response Body: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}...",
      );

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
          print("   Respostas: $extractedAnswers");

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
      print("🔌 Testando conexão com a API OMR...");
      print("   URL: $omrApiUrl"); // 🔥 Usa a URL do config.dart

      final response = await http.get(Uri.parse("$omrApiUrl/"));

      print("   Status: ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Erro de conexão: $e");
      return false;
    }
  }
}
