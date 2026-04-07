// lib/features/exams/screens/edit_answers_screen.dart
import 'package:flutter/material.dart';

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
        title: const Text("Editar Respostas"),
        backgroundColor: const Color(0xff004aad),
        foregroundColor: Colors.white,
        // 🔥 Botão Salvar removido da AppBar
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
                  // Se for o último item, mostrar o botão Salvar
                  if (index == _editedAnswers.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          "SALVAR ALTERAÇÕES",
                          style: TextStyle(
                            fontSize: 16,
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
                    );
                  }
                  
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
                          
                          // Botões Branco e Marcação Dupla (sem símbolos internos)
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

  void _saveChanges() {
    // Chamar o callback com as respostas editadas
    widget.onAnswersUpdated(_editedAnswers);
    
    // Mostrar mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Respostas salvas com sucesso!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Voltar para tela anterior
    Navigator.pop(context);
  }
}