// lib/features/answer_sheet/screens/review_answer_sheet_screen.dart
import 'package:flutter/material.dart';

class ReviewAnswerSheetScreen extends StatelessWidget {
  final String studentName;
  final String examName;
  final List<String?> answers;
  final int numberOfQuestions; // Adicionado

  const ReviewAnswerSheetScreen({
    super.key,
    required this.studentName,
    required this.examName,
    required this.answers,
    required this.numberOfQuestions,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar quantas alternativas baseado no número de questões
    final int alternativesCount = numberOfQuestions == 20 ? 5 : 4;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Revisar Gabarito"),
        backgroundColor: const Color(0xff004aad),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$numberOfQuestions questões • $alternativesCount alternativas",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Resumo estatístico
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSummaryCard(),
          ),
          
          const SizedBox(height: 16),
          
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
  
  Widget _buildSummaryCard() {
    final answered = answers.where((a) => a != null).length;
    final total = answers.length;
    final blankAnswers = answers.where((a) => a == "Branco").length;
    final doubleMarks = answers.where((a) => a == "Marcação dupla").length;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            "Identificadas",
            "$answered/$total",
            Icons.check_circle,
            Colors.green,
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            "Branco",
            blankAnswers.toString(),
            Icons.radio_button_unchecked,
            Colors.blue,
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            "Marc. Dupla",
            doubleMarks.toString(),
            Icons.change_circle,
            Colors.purple,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  String _getDisplayText(String? answer) {
    if (answer == null) {
      return "?";
    } else if (answer == "Em branco") {
      return "∅";
    } else if (answer == "Marcação dupla") {
      return "⊜";
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