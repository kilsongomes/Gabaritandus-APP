// lib/features/exams/screens/capture_answer_sheet_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/answer_sheet_controller.dart';
import 'edit_answers_screen.dart'; // Nova importação

class CaptureAnswerSheetScreen extends StatefulWidget {
  final String studentName;
  final String examName;
  final dynamic studentId;
  final String examId;
  final String examGrade;

  const CaptureAnswerSheetScreen({
    super.key,
    required this.studentName,
    required this.examName,
    required this.studentId,
    required this.examId,
    required this.examGrade,
  });

  @override
  State<CaptureAnswerSheetScreen> createState() =>
      _CaptureAnswerSheetScreenState();
}

class _CaptureAnswerSheetScreenState extends State<CaptureAnswerSheetScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnswerSheetController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Capturar gabarito"),
          backgroundColor: const Color(0xFF00B4D8),
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Consumer<AnswerSheetController>(
            builder: (context, controller, _) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informações do aluno/exame
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.all(0),
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
                            const SizedBox(height: 8),
                            const Text(
                              "",
                              style: TextStyle(fontSize: 3, color: Colors.grey),
                            ),
                            Text(
                              widget.examName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.examGrade,
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

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _buildImagePreview(controller),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botões de ação
                    _buildActionButtons(controller),

                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(AnswerSheetController controller) {
    if (controller.isProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image(
                image: AssetImage('assets/images/processing.gif'),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Processando imagem..."),
            SizedBox(height: 8),
            Text(
              "Analisando respostas...",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (controller.capturedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(controller.capturedImage!.path),
          fit: BoxFit.contain,
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Nenhuma imagem capturada",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600],),
          ),
          const SizedBox(height: 8),
          Text(
            "Use o botão abaixo para \ncapturar uma imagem",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500],fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AnswerSheetController controller) {
    if (controller.extractedAnswers != null) {
      return Column(
        children: [
          // Mostrar respostas extraídas
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              children: [
                const Text(
                  "Respostas detectadas:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.extractedAnswers!.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final answer = entry.value;
                    final isEdited = controller.editedQuestions[index];

                    // Cor baseada em edição
                    Color chipColor;
                    if (isEdited) {
                      chipColor = Colors.orange[100]!; // Laranja se editado
                    } else if (answer != null) {
                      chipColor = Colors.green[100]!; // Verde se detectado
                    } else {
                      chipColor = Colors.grey[200]!; // Cinza se não detectado
                    }

                    return Chip(
                      label: answer == null
                          ? const SizedBox(
                              width: 30, // Largura fixa igual aos outros chips
                              child: Center(
                                child: Icon(
                                  Icons.crop_square,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Text("${index + 1}: $answer"),
                      backgroundColor: chipColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ), // Padding uniforme
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Botão Nova Captura
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Nova Captura"),
                  onPressed: () {
                    controller.resetEditedFlags(); // Resetar flags
                    controller.clear();
                  },
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAnswersScreen(
                          studentName: widget.studentName,
                          examName: widget.examName,
                          answers: controller.extractedAnswers!,
                          editedQuestions: controller.editedQuestions,
                          onAnswersUpdated: (updatedAnswers) {
                            controller.updateExtractedAnswers(updatedAnswers);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Botão Confirmar
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text("Confirmar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _confirmAnswers(controller.extractedAnswers!);
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Botão de captura
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt, color: Colors.white,size: 30,),
            label: const Text(
              "Tirar foto",
              style: TextStyle(color: Colors.white, fontSize: 18,),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B4D8),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: controller.isProcessing
                ? null
                : () => controller.captureWithOverlay(
                    context,
                    studentName: widget.studentName,
                    examName: widget.examName,
                    studentId: widget.studentId,
                    examId: widget.examId,
                  ),
          ),
        ),
      ],
    );
  }

  void _confirmAnswers(List<String?> answers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sucesso!"),
        content: Text(
          "Gabarito de ${widget.studentName} capturado com sucesso.\n"
          "Respostas: ${answers.where((a) => a != null).length} de 10 detectadas",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha dialog
              Navigator.pop(context); // Volta para tela anterior
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
