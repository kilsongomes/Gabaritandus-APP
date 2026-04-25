// lib/features/answer_sheet/controller/answer_sheet_confirmation_controller.dart
import 'package:flutter/material.dart';

class AnswerSheetConfirmationController extends ChangeNotifier {
  bool _isProcessing = false;
  bool _hasAllAnswers = false;
  String? _errorMessage;

  bool get isProcessing => _isProcessing;
  bool get hasAllAnswers => _hasAllAnswers;
  String? get errorMessage => _errorMessage;

  /// Verifica se todas as questões foram respondidas
  bool checkAllAnswers(List<String?> answers) {
    _hasAllAnswers = answers.every((answer) => answer != null);
    notifyListeners();
    return _hasAllAnswers;
  }

  /// Obtém a lista de questões não identificadas
  List<int> getUnansweredQuestions(List<String?> answers) {
    final unanswered = <int>[];
    for (int i = 0; i < answers.length; i++) {
      if (answers[i] == null) {
        unanswered.add(i + 1); // +1 porque questão começa em 1
      }
    }
    return unanswered;
  }

  // Formata a lista de questões para exibição
  String _formatQuestionsList(List<int> questions) {
    if (questions.isEmpty) return '';

    if (questions.length == 1) {
      return 'a questão ${questions[0]}';
    }

    if (questions.length == 2) {
      return 'as questões ${questions[0]} e ${questions[1]}';
    }

    // Para 3 ou mais questões, separar por vírgulas e "e" antes do último
    final lastQuestion = questions.removeLast();
    final formattedList = questions.join(', ');
    return 'as questões $formattedList e $lastQuestion';
  }

  /// Mostra modal de aviso para respostas faltantes
  /// Retorna true se o usuário confirmou que entendeu
  Future<bool> showMissingAnswersDialog(
    BuildContext context, {
    required List<String?> answers,
  }) async {
    final unansweredQuestions = getUnansweredQuestions(answers);
    final formattedQuestions = _formatQuestionsList(unansweredQuestions);

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Color(0xffe5edfa),
            title: Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 28,
                  color: Colors.orange,
                ),
                SizedBox(width: 10), // Espaço entre o ícone e o texto
                Text(
                  "Atenção!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize
                  .min, // Importante: faz a coluna ocupar o espaço mínimo
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Antes de enviar, revise e edite $formattedQuestions.",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20), // Espaço antes da linha
                const Divider(
                  color: Colors.grey, // Cor da linha
                  thickness: 1, // Grossura da linha
                  height: 1, // Espaço que o widget ocupa
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff004aad),
                  foregroundColor: Colors.white,
                ),
                child: const Center(child: Text("Fechar")),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Mostra modal de sucesso quando todas respostas são identificadas
  Future<bool> showSuccessDialog(
    BuildContext context, {
    required List<String?> answers,
    required int numberOfQuestions, // Adicionar este parâmetro
  }) async {
    final answeredCount = answers.where((a) => a != null).length;
    final totalCount = answers.length;

    return await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color(0xffe5edfa),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: const Color(0xFF004aad),
                  size: 28,
                ),

                const SizedBox(width: 10),
                const Text(
                  "Gabarito Completo!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Agora apenas o ícone e o texto, sem o Container azul
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "$answeredCount de $totalCount respostas detectadas corretamente",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Espaçamento antes da linha
                const Divider(color: Colors.grey, thickness: 1, height: 1),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF004aad),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Revisar Gabarito"),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Mostra modal de loading
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Processando gabarito..."),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void hideLoadingDialog(BuildContext context) {
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void reset() {
    _isProcessing = false;
    _hasAllAnswers = false;
    _errorMessage = null;
    notifyListeners();
  }
}
