import 'package:gabaritandus/features/answer_sheet/services/answer_sheet_api_service.dart';

class AnswerSheetProcessor {
  final AnswerSheetApiService _apiService = AnswerSheetApiService();

  Future<List<String?>> processAnswerSheet(
    dynamic imageFile,
    int numberOfQuestions,
  ) async {
    print("📷 Iniciando processamento da folha via API...");
    print("   Número de questões: $numberOfQuestions");

    try {
      final answers = await _apiService.processAnswerSheet(
        imageFile,
        numberOfQuestions,
      );

      return answers;
    } catch (e) {
      print("❌ [AnswerSheetProcessor] Erro ao processar: $e");
      rethrow;
    }
  }
}
