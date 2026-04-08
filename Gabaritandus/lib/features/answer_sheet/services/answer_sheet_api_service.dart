import 'dart:convert';
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

      // Escolher endpoint
      final endpoint = numberOfQuestions == 20
          ? "/processar_20_questoes"
          : "/processar_10_questoes";

      final uri = Uri.parse("$baseUrl$endpoint");

      print("   URL: $uri");

      // 👇 IMPORTANTE: na web usamos MultipartRequest
      final request = http.MultipartRequest("POST", uri);

      // Headers
      request.headers.addAll({"Accept": "application/json"});

      // 👇 diferença principal aqui
      if (kIsWeb) {
        // imageFile deve ser Uint8List
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageFile,
            filename: 'answer_sheet.jpg',
          ),
        );
      } else {
        // Mobile continua igual
        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );
      }

      print("   Enviando requisição...");

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      print("   Status Code: ${response.statusCode}");
      print("⬅️ [AnswerSheetApiService] Response Body: $responseBody");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        if (data["success"] == true) {
          final respostasRaw = data["respostas"] as List;
          final totalQuestoes = data["questoes"] as int;

          print("   Total de questões esperadas: $totalQuestoes");
          print("   Respostas recebidas: ${respostasRaw.length}");

          List<String?> extractedAnswers = List<String?>.filled(
            totalQuestoes,
            null,
          );

          for (var item in respostasRaw) {
            final numero = item["numero"] as int;
            final resposta = item["resposta"] as String?;
            final respondida = item["respondida"] as bool;

            print(
              "   Questão $numero: respondida=$respondida, resposta=$resposta",
            );

            if (respondida && resposta != null && resposta.isNotEmpty) {
              final index = numero - 1;
              if (index < extractedAnswers.length) {
                extractedAnswers[index] = resposta;
              }
            }
          }

          final totalRespondidas = extractedAnswers
              .where((a) => a != null)
              .length;

          print("✅ [AnswerSheetApiService] Processamento concluído");
          print(
            "   Total de respostas detectadas: $totalRespondidas de $totalQuestoes",
          );

          return extractedAnswers;
        } else {
          throw Exception(data["message"] ?? "Erro ao processar imagem");
        }
      } else {
        throw Exception("Erro HTTP ${response.statusCode}: $responseBody");
      }
    } catch (e) {
      print("❌ [AnswerSheetApiService] Erro: $e");
      rethrow;
    }
  }

  Future<bool> testConnection() async {
    try {
      print("🔌 [AnswerSheetApiService] Testando conexão com a API...");

      final response = await http.get(Uri.parse("$baseUrl/"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ [AnswerSheetApiService] Conexão OK!");
        print("   Resposta: ${data['message']}");
        return true;
      } else {
        print(
          "❌ [AnswerSheetApiService] Erro na conexão: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("❌ [AnswerSheetApiService] Erro de conexão: $e");
      return false;
    }
  }
}
