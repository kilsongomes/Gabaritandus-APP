// lib/features/exams/screens/edit_answers_screen.dart
import 'package:flutter/material.dart';

class EditAnswersScreen extends StatefulWidget {
  final String studentName;
  final String examName;
  final List<String?> answers;
  final List<bool> editedQuestions;
  final Function(List<String?>) onAnswersUpdated;

  const EditAnswersScreen({
    super.key,
    required this.studentName,
    required this.examName,
    required this.answers,
    required this.editedQuestions,
    required this.onAnswersUpdated,
  });

  @override
  State<EditAnswersScreen> createState() => _EditAnswersScreenState();
}

class _EditAnswersScreenState extends State<EditAnswersScreen> {
  late List<String?> _editedAnswers;
  late List<bool> _locallyEdited;
  static const List<String> options = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    // Copiar as respostas para edição
    _editedAnswers = List.from(widget.answers);
    _locallyEdited = List.from(widget.editedQuestions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Respostas"),
        backgroundColor: const Color(0xff004aad),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card com informações do aluno e exame
            Card(
              elevation: 2,
              color: const Color(0xffe5edfa),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      widget.studentName,
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
                      widget.examName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Lista de questões
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                // Adicionamos +1 para o botão ao final
                itemCount: _editedAnswers.length + 1,
                itemBuilder: (context, index) {
                  // Se for o último índice, retornamos o botão de salvar
                  if (index == _editedAnswers.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff004aad),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "SALVAR",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  // Caso contrário, renderiza o Card da questão normalmente
                  final questionNumber = index + 1;
                  final selectedOption = _editedAnswers[index];
                  final wasEdited = _locallyEdited[index];

                  return Card(
                    color: Colors.white70,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Número da questão com indicador de edição
                          Row(
                            children: [
                              Text(
                                "Questão $questionNumber",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: wasEdited
                                      ? Colors.orange
                                      : Colors.black,
                                ),
                              ),
                              if (wasEdited) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "Editada",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Opções A, B, C, D (círculos ocupando todo o espaço)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: options.map((option) {
                              final isSelected = selectedOption == option;

                              return Expanded(
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        // Se clicar na mesma opção, desmarca
                                        if (isSelected) {
                                          _editedAnswers[index] = null;
                                        } else {
                                          _editedAnswers[index] = option;
                                        }
                                        _locallyEdited[index] = true;
                                      });
                                    },
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.grey[600]
                                            : Colors.grey[200],
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.grey[600]!
                                              : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // Botões Branco e Marcação Dupla na parte inferior (retangulares)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (selectedOption == "Branco") {
                                        _editedAnswers[index] = null;
                                      } else {
                                        _editedAnswers[index] = "Branco";
                                      }
                                      _locallyEdited[index] = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selectedOption == "Branco"
                                          ? Colors.grey[600]
                                          : Colors.grey[200],
                                      border: Border.all(
                                        color: selectedOption == "Branco"
                                            ? Colors.grey[600]!
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Branco",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: selectedOption == "Branco"
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (selectedOption == "Marcação dupla") {
                                        _editedAnswers[index] = null;
                                      } else {
                                        _editedAnswers[index] =
                                            "Marcação dupla";
                                      }
                                      _locallyEdited[index] = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selectedOption == "Marcação dupla"
                                          ? Colors.grey[600]
                                          : Colors.grey[200],
                                      border: Border.all(
                                        color:
                                            selectedOption == "Marcação dupla"
                                            ? Colors.grey[600]!
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Marcação dupla",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              selectedOption == "Marcação dupla"
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    // Chamar o callback com as respostas editadas
    widget.onAnswersUpdated(_editedAnswers);

    // Voltar para tela anterior
    Navigator.pop(context);
  }
}
