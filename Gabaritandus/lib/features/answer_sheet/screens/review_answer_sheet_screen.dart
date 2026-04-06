// lib/features/answer_sheet/screens/review_answer_sheet_screen.dart
import 'package:flutter/material.dart';

class ReviewAnswerSheetScreen extends StatelessWidget {
  final String studentName;
  final String examName;
  final List<String?> answers;

  const ReviewAnswerSheetScreen({
    super.key,
    required this.studentName,
    required this.examName,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Revisar Gabarito"),
        backgroundColor: const Color(0xff004aad),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implementar confirmação final
              _confirmAndFinish(context);
            },
            child: const Text(
              "FINALIZAR",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Informações do aluno
          Card(
            margin: const EdgeInsets.all(16),
            color: const Color(0xffe5edfa),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Estudante",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Avaliação",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    examName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Lista de respostas para revisão
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: answers.length,
              itemBuilder: (context, index) {
                final questionNumber = index + 1;
                final answer = answers[index];
                final displayText = _getDisplayText(answer);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xff004aad),
                      child: Text(
                        "$questionNumber",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      "Questão $questionNumber",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: answer == null
                            ? Colors.orange.withValues(alpha: 0.3)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: answer == null ? Colors.orange : Colors.green,
                        ),
                      ),
                      child: Text(
                        displayText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: answer == null ? Colors.orange[800] : Colors.green[800],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Botão Editar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Editar Respostas"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  // Voltar para edição
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getDisplayText(String? answer) {
    if (answer == null) {
      return "?";
    } else if (answer == "Branco") {
      return "B";
    } else if (answer == "Marcação dupla") {
      return "!!";
    } else {
      return answer;
    }
  }
  
  void _confirmAndFinish(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Gabarito"),
        content: const Text(
          "Tem certeza que deseja finalizar e enviar este gabarito?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fecha dialog
              // TODO: Enviar para API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Gabarito enviado com sucesso!"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }
}