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
        actions: [
          // Botão Salvar
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              "SALVAR",
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
          // Informações do aluno/exame
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.studentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.examName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de questões
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _editedAnswers.length,
              itemBuilder: (context, index) {
                final questionNumber = index + 1;
                final selectedOption = _editedAnswers[index];
                final wasEdited = _locallyEdited[index];

                return Card(
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
                                color: wasEdited ? Colors.orange : Colors.black,
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
                        const SizedBox(height: 12),

                        // Opções A, B, C, D e botões Branco/Rasura
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ...options.map((option) {
                                final isSelected = selectedOption == option;

                                return GestureDetector(
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      children: [
                                        // Bolinha
                                        Container(
                                          width: 50,
                                          height: 50,
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
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),

                              // Botões Branco e Rasura (um acima do outro)
                              Container(
                                width: 60,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: [
                                    // Botão Branco (texto "Branco")
                                    GestureDetector(
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
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: selectedOption == "Branco"
                                              ? Colors.grey[600]
                                              : Colors.white,
                                          border: Border.all(
                                            color: selectedOption == "Branco"
                                                ? Colors.grey[600]!
                                                : Colors.grey[400]!,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Branco",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Botão Rasura (texto "Rasura")
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selectedOption == "Rasura") {
                                            _editedAnswers[index] = null;
                                          } else {
                                            _editedAnswers[index] = "Rasura";
                                          }
                                          _locallyEdited[index] = true;
                                        });
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: selectedOption == "Rasura"
                                              ? Colors.grey
                                              : Colors.white,
                                          border: Border.all(
                                            color: selectedOption == "Rasura"
                                                ? Colors.grey[600]!
                                                : Colors.grey[400]!,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Rasura",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  void _saveChanges() {
    // Chamar o callback com as respostas editadas
    widget.onAnswersUpdated(_editedAnswers);

    // Voltar para tela anterior
    Navigator.pop(context);
  }
}
