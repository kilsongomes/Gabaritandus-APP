import 'dart:io';
import 'package:gabaritandus/features/answer_sheet/services/answer_sheet_api_service.dart';

class AnswerSheetProcessor {
  final AnswerSheetApiService _apiService = AnswerSheetApiService();
  
  // parâmetro para número de questões
  Future<List<String?>> processAnswerSheet(File imageFile, int numberOfQuestions) async {
    print("📷 Iniciando processamento da folha via API...");
    print("   Número de questões: $numberOfQuestions");
    
    try {
      // Chamar a API
      final answers = await _apiService.processAnswerSheet(imageFile, numberOfQuestions);
      return answers;
    } catch (e) {
      print("❌ [AnswerSheetProcessor] Erro ao processar: $e");
      rethrow;
    }
  }
}