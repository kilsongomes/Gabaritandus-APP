// lib/features/exams/screens/capture_answer_sheet_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/answer_sheet_controller.dart';

class CaptureAnswerSheetScreen extends StatefulWidget {
  final String studentName;
  final String examName;
  final dynamic studentId;
  final String examId;

  const CaptureAnswerSheetScreen({
    super.key,
    required this.studentName,
    required this.examName,
    required this.studentId,
    required this.examId,
  });

  @override
  State<CaptureAnswerSheetScreen> createState() => _CaptureAnswerSheetScreenState();
}

class _CaptureAnswerSheetScreenState extends State<CaptureAnswerSheetScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnswerSheetController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Capturar Gabarito"),
          backgroundColor: const Color(0xFF00B4D8),
          foregroundColor: Colors.white,
        ),
        body: SafeArea( // 🔥 CORREÇÃO: Envolver com SafeArea
          child: Consumer<AnswerSheetController>(
            builder: (context, controller, _) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informações do aluno/exame
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Aluno",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
                              "Exame",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              widget.examName,
                              style: const TextStyle(fontSize: 16),
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
                    
                    // Botões de ação - SEMPRE VISÍVEIS
                    _buildActionButtons(controller),
                    
                    // 🔥 ADICIONADO: Espaçamento extra para garantir que não fique atrás dos botões
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
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Processando imagem..."),
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
          Icon(
            Icons.camera_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Nenhuma imagem capturada",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Use os botões abaixo para capturar ou\nselecionar uma imagem",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
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
                  runSpacing: 8, // 🔥 ADICIONADO: espaçamento entre linhas
                  children: controller.extractedAnswers!.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final answer = entry.value ?? "?";
                    return Chip(
                      label: Text("$index: $answer"),
                      backgroundColor: Colors.green[100],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Nova Captura"),
                  onPressed: controller.clear,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text("Confirmar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Tirar Foto"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B4D8),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: controller.isProcessing 
                ? null 
                : () => controller.captureFromCamera(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text("Galeria"),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00B4D8),
              side: const BorderSide(color: Color(0xFF00B4D8)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: controller.isProcessing 
                ? null 
                : () => controller.pickFromGallery(),
          ),
        ),
      ],
    );
  }

  void _confirmAnswers(List<String?> answers) {
    // TODO: Enviar respostas para o backend
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sucesso!"),
        content: Text(
          "Gabarito de ${widget.studentName} capturado com sucesso.\n"
          "Respostas: ${answers.where((a) => a != null).length} de 10 detectadas"
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