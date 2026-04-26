// lib/features/exams/screens/edit_answers_screen.dart
import 'package:flutter/material.dart';
import '../../answer_sheet/screens/review_answer_sheet_screen.dart';

class EditAnswersScreen extends StatefulWidget {
  final String studentName;
  final String examName;
  final List<String?> answers;
  final List<bool> editedQuestions;
  final int numberOfQuestions;
  final Function(List<String?>) onAnswersUpdated;

  const EditAnswersScreen({
    super.key,
    required this.studentName,
    required this.examName,
    required this.answers,
    required this.editedQuestions,
    required this.numberOfQuestions,
    required this.onAnswersUpdated,
  });

  @override
  State<EditAnswersScreen> createState() => _EditAnswersScreenState();
}

class _EditAnswersScreenState extends State<EditAnswersScreen> {
  late List<String?> _editedAnswers;
  late List<bool> _locallyEdited;
  late List<String> options;

  @override
  void initState() {
    super.initState();
    // Definir opções baseado no número de questões
    if (widget.numberOfQuestions == 20) {
      options = ['A', 'B', 'C', 'D', 'E'];
    } else {
      options = ['A', 'B', 'C', 'D'];
    }
    
    // Copiar as respostas para edição
    _editedAnswers = List.from(widget.answers);
    _locallyEdited = List.from(widget.editedQuestions);
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar respostas"),
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

            // Lista de questões com botão no final
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _editedAnswers.length + 1, // +1 para o botão
                itemBuilder: (context, index) {
                  // Se for o último item, mostrar o botão
                  if (index == _editedAnswers.length) {
                    return Padding(                      
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          // Botão Cancelar
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context); // Volta sem salvar
                              },
                              icon: const Icon(Icons.close),
                              label: const Text(
                                "CANCELAR",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Botão Salvar e Revisar
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveAndReview,
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text(
                                "SALVAR",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final questionNumber = index + 1;
                  final selectedOption = _editedAnswers[index];
                  final wasEdited = _locallyEdited[index];                  

                  return Card(
                    color: const Color(0xffe5edfa),
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
                          const SizedBox(height: 16),                         
          
                          // Opções A, B, C, D, E (círculos)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: options.map((option) {
                              final isSelected = selectedOption == option;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _editedAnswers[index] = null;
                                    } else {
                                      _editedAnswers[index] = option;
                                    }
                                    _locallyEdited[index] = true;
                                  });
                                },
                                child: Container(
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
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Botões Branco e Marcação Dupla
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (selectedOption == "Em branco") {
                                        _editedAnswers[index] = null;
                                      } else {
                                        _editedAnswers[index] = "Em branco";
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
                                      color: selectedOption == "Em branco"
                                          ? Colors.grey[600]
                                          : Colors.grey[200],
                                      border: Border.all(
                                        color: selectedOption == "Em branco"
                                            ? Colors.grey[600]!
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Em branco",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: selectedOption == "Em branco"
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
                                        _editedAnswers[index] = "Marcação dupla";
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
                                        color: selectedOption == "Marcação dupla"
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
                                          color: selectedOption == "Marcação dupla"
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

  void _saveAndReview() {
    // Atualizar as respostas no controller
    widget.onAnswersUpdated(_editedAnswers);
    
    // Navegar diretamente para a tela de revisão
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewAnswerSheetScreen(
          studentName: widget.studentName,
          examName: widget.examName,
          answers: _editedAnswers,
          numberOfQuestions: widget.numberOfQuestions,
        ),
      ),
    );
  }
}