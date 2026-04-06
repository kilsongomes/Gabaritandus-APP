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

  /// Obtém estatísticas das respostas
  Map<String, dynamic> getAnswerStats(List<String?> answers) {
    final total = answers.length;
    final answered = answers.where((a) => a != null).length;
    final unanswered = total - answered;
    final blankAnswers = answers.where((a) => a == "Branco").length;
    final doubleMarks = answers.where((a) => a == "Marcação dupla").length;
    
    return {
      'total': total,
      'answered': answered,
      'unanswered': unanswered,
      'blankAnswers': blankAnswers,
      'doubleMarks': doubleMarks,
    };
  }

  /// Mostra modal de aviso para respostas faltantes
  /// Retorna true se o usuário confirmou que entendeu
  Future<bool> showMissingAnswersDialog(
    BuildContext context, {
    required List<String?> answers,
  }) async {
    final stats = getAnswerStats(answers);
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text(
              "Atenção!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "A leitura do gabarito não identificou todas as respostas.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    "Total de questões:",
                    "${stats['total']}",
                    Icons.help_outline,
                  ),
                  const Divider(),
                  _buildStatRow(
                    "Respostas identificadas:",
                    "${stats['answered']}",
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildStatRow(
                    "Não identificadas:",
                    "${stats['unanswered']}",
                    Icons.error_outline,
                    color: Colors.orange,
                  ),
                  if (stats['blankAnswers'] > 0)
                    _buildStatRow(
                      "Questões em branco:",
                      "${stats['blankAnswers']}",
                      Icons.radio_button_unchecked,
                      color: Colors.blue,
                    ),
                  if (stats['doubleMarks'] > 0)
                    _buildStatRow(
                      "Marcações duplas:",
                      "${stats['doubleMarks']}",
                      Icons.change_circle,
                      color: Colors.purple,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Você pode editar as respostas manualmente antes de continuar.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text("Entendi"),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color ?? Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra modal de sucesso quando todas respostas são identificadas
  Future<bool> showSuccessDialog(
    BuildContext context, {
    required List<String?> answers,
  }) async {
    final stats = getAnswerStats(answers);
    
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
            const Text(
              "Todas as respostas foram identificadas com sucesso!",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    "Total de questões:",
                    "${stats['total']}",
                    Icons.help_outline,
                    color: Colors.grey,
                  ),
                  const Divider(),
                  _buildStatRow(
                    "Respostas identificadas:",
                    "${stats['answered']}",
                    Icons.check_circle,
                    color: Colors.green,
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