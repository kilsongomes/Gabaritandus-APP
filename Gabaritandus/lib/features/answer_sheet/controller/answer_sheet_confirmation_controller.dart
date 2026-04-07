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

  /// Formata a lista de questões para exibição
  String _formatQuestionsList(List<int> questions) {
    if (questions.isEmpty) return '';
    
    if (questions.length == 1) {
      return '${questions[0]}';
    }
    
    // Verificar se são questões consecutivas
    final List<String> parts = [];
    int start = questions[0];
    int end = questions[0];
    
    for (int i = 1; i < questions.length; i++) {
      if (questions[i] == end + 1) {
        end = questions[i];
      } else {
        if (start == end) {
          parts.add('$start');
        } else {
          parts.add('$start-$end');
        }
        start = questions[i];
        end = questions[i];
      }
    }
    
    // Adicionar o último intervalo
    if (start == end) {
      parts.add('$start');
    } else {
      parts.add('$start-$end');
    }
    
    if (parts.length == 1) {
      return parts[0];
    } else if (parts.length == 2) {
      return '${parts[0]} e ${parts[1]}';
    } else {
      final lastPart = parts.removeLast();
      return '${parts.join(', ')} e $lastPart';
    }
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
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, size: 28),
            SizedBox(width: 8),
            Text(
              "Atenção!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.grey[800], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Antes de enviar, revise e edite as alternativas ${unansweredQuestions.length == 1 ? '' : 'das questões '}$formattedQuestions",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),            
          ],
        ),
        actions: [          
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Center(child: const Text("Entendi")),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Mostra modal de sucesso quando todas respostas são identificadas
  Future<bool> showSuccessDialog(
  BuildContext context, {
  required List<String?> answers,
  required int numberOfQuestions, // Adicionar este parâmetro
}) async {
  final answeredCount = answers.where((a) => a != null).length;
  final totalCount = answers.length;
  final alternativesCount = numberOfQuestions == 20 ? 5 : 4;
  
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 8),
          Text(
            "Gabarito Completo!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Todas as $totalCount questões foram identificadas com sucesso!",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "($alternativesCount alternativas por questão)",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.verified, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "$answeredCount de $totalCount respostas detectadas corretamente",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Deseja revisar o gabarito antes de finalizar?",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text("Voltar"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text("Revisar Gabarito"),
        ),
      ],
    ),
  ) ?? false;
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