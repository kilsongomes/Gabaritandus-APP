// lib/features/exams/screens/capture_answer_sheet_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/answer_sheet_controller.dart';
import 'edit_answers_screen.dart';
import '../services/answer_sheet_api_service.dart';
import '../controller/api_config.dart';
import '../controller/answer_sheet_confirmation_controller.dart';
import 'review_answer_sheet_screen.dart';

class CaptureAnswerSheetScreen extends StatefulWidget {
  final String studentName;
  final String examName;
  final dynamic studentId;
  final String examId;
  final String examGrade;
  final int numberOfQuestions;

  const CaptureAnswerSheetScreen({
    super.key,
    required this.studentName,
    required this.examName,
    required this.studentId,
    required this.examId,
    required this.examGrade,
    required this.numberOfQuestions,
  });

  @override
  State<CaptureAnswerSheetScreen> createState() =>
      _CaptureAnswerSheetScreenState();
}

class _CaptureAnswerSheetScreenState extends State<CaptureAnswerSheetScreen> {
  @override
  void initState() {
    super.initState();
    // Testar conexão com a API ao abrir a tela
    _testApiConnection();
  }

  Future<void> _testApiConnection() async {
    final apiService = AnswerSheetApiService();
    final isConnected = await apiService.testConnection();

    if (!isConnected && mounted) {
      // Mostrar aviso se não conseguir conectar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível conectar à API em ${ApiConfig.baseUrl}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API conectada com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnswerSheetController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Capturar gabarito"),
          backgroundColor: const Color(0xff004aad),
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
                      color: Color(0xffe5edfa),
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
                              "Avaliação",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.examName} - (${widget.examGrade})',

                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "",
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
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            "Use o botão abaixo para \ncapturar uma imagem",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
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
              color: Color(0xffe5edfa),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Cabeçalho com título e botão de editar na mesma linha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Respostas detectadas:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),
                    // Botão Editar com visual de card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAnswersScreen(
                                  studentName: widget.studentName,
                                  examName: widget.examName,
                                  answers: controller.extractedAnswers!,
                                  editedQuestions: controller.editedQuestions,
                                  onAnswersUpdated: (updatedAnswers) {
                                    controller.updateExtractedAnswers(
                                      updatedAnswers,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.edit, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  "Editar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Chips das respostas
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.extractedAnswers!.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final answer = entry.value;
                    final isEdited = controller.editedQuestions[index];

                    // Determinar a cor baseada no valor
                    Color chipColor;
                    String displayText;

                    if (isEdited) {
                      chipColor = Colors.orange[100]!; // Laranja se editado
                    } else if (answer == null) {
                      chipColor = Colors.orange.withValues(
                        alpha: 0.3,
                      ); // Laranja claro para null
                    } else {
                      chipColor = Colors.white10; // Branco se detectado
                    }

                    // Determinar o texto a ser exibido
                    if (answer == null) {
                      displayText = "?";
                    } else if (answer == "Branco") {
                      displayText = "∅";
                    } else if (answer == "Marcação dupla") {
                      displayText = "●●";
                    } else {
                      displayText = answer;
                    }

                    return Chip(
                      label: Text("${index + 1}. $displayText"),
                      backgroundColor: chipColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff004aad),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    controller.resetEditedFlags();
                    controller.clear();
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
            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
            label: const Text(
              "Tirar foto",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff004aad),
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
                    numberOfQuestions: widget.numberOfQuestions,
                  ),
          ),
        ),
      ],
    );
  }

 void _confirmAnswers(List<String?> answers) async {
  final confirmationController = AnswerSheetConfirmationController();
  
  // Verificar se todas as respostas foram identificadas
  final hasAllAnswers = confirmationController.checkAllAnswers(answers);
  
  if (hasAllAnswers) {
    // Cenário 1: Todas as respostas foram lidas
    final shouldReview = await confirmationController.showSuccessDialog(
      context,
      answers: answers,
    );
    
    if (shouldReview) {
      _navigateToReviewScreen(answers);
    }
  } else {
    // Cenário 2: Faltam respostas - mostrar modal de aviso
    final understood = await confirmationController.showMissingAnswersDialog(
      context,
      answers: answers,
    );
    
    if (understood) {
      // Usuário entendeu que faltam respostas e vai editar manualmente
      // Fecha a tela atual? Ou apenas mostra onde editar?
      // Vamos apenas mostrar um snackbar indicando onde editar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Clique no botão "Editar" acima para corrigir as respostas manualmente',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

  void _showSuccessAndNavigateToReview(List<String?> answers) async {
    final confirmationController = AnswerSheetConfirmationController();
    final stats = confirmationController.getAnswerStats(answers);

    // Mostrar diálogo de sucesso
    final shouldContinue =
        await showDialog<bool>(
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
        ) ??
        false;

    if (shouldContinue) {
      // Navegar para tela de revisão
      _navigateToReviewScreen(answers);
    }
  }

  void _navigateToEditAndThenToReview(List<String?> answers) async {
    // Navegar para edição e aguardar o resultado
    final editedAnswers = await Navigator.push<List<String?>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditAnswersScreen(
          studentName: widget.studentName,
          examName: widget.examName,
          answers: answers,
          editedQuestions: List.filled(answers.length, true),
          onAnswersUpdated: (updatedAnswers) {
            // Atualizar no controller
            final controller = Provider.of<AnswerSheetController>(
              context,
              listen: false,
            );
            controller.updateExtractedAnswers(updatedAnswers);
          },
        ),
      ),
    );

    if (editedAnswers != null && context.mounted) {
      // Após editar, verificar se agora está completo
      final confirmationController = AnswerSheetConfirmationController();
      final hasAllAnswers = confirmationController.checkAllAnswers(
        editedAnswers,
      );

      if (hasAllAnswers) {
        // Agora está completo, ir para revisão
        _navigateToReviewScreen(editedAnswers);
      } else {
        // Ainda faltam respostas, mostrar aviso novamente
        final shouldEditAgain = await confirmationController
            .showMissingAnswersDialog(
              context,
              answers: editedAnswers,
              
            );

        if (shouldEditAgain == false) {
          // Usuário cancelou, voltar para tela anterior
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      }
    }
  }

  void _navigateToReviewScreen(List<String?> answers) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReviewAnswerSheetScreen(
        studentName: widget.studentName,
        examName: widget.examName,
        answers: answers,
      ),
    ),
  );
}

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
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
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
}
