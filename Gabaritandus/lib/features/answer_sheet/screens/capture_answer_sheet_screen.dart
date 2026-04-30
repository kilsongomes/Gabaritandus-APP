// lib/features/exams/screens/capture_answer_sheet_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/answer_sheet_controller.dart';
import 'edit_answers_screen.dart';
import '../services/answer_sheet_api_service.dart';
import '../controller/api_config.dart';
import '../controller/answer_sheet_confirmation_controller.dart';
import '../../answer_sheet/screens/review_answer_sheet_screen.dart';

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
  final ScrollController _answersScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _testApiConnection();
  }

  @override
  void dispose() {
    _answersScrollController.dispose();
    super.dispose();
  }

  Future<void> _testApiConnection() async {
    final apiService = AnswerSheetApiService();
    final isConnected = await apiService.testConnection();

    if (!isConnected && mounted) {
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

  /// Formata o número da questão com 2 dígitos (espaço invisível para 1-9)
  String _formatQuestionNumber(int number) {
    if (number < 10) {
      return ' $number'; // Espaço antes do número para ter 2 caracteres
    }
    return '$number';
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
                      color: const Color(0xffe5edfa),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.zero,
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
                            const SizedBox(height: 3),
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
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Área da imagem com altura flexível
                    Flexible(
                      flex: 4,
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

                    // Área das respostas detectadas com altura flexível e scroll
                    Flexible(flex: 4, child: _buildAnswersSection(controller)),

                    const SizedBox(height: 12),

                    // Botões de ação (fixos no final)
                    _buildActionButtons(controller),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Mostra a imagem em tela cheia com zoom
  void _showFullScreenImage(AnswerSheetController controller) {
    if (controller.capturedImage == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xffe5edfa),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Color(0xffe5edfa),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // Container de clipe para manter o zoom dentro dos limites
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    boundaryMargin: const EdgeInsets.all(
                      20,
                    ), // 🔥 Margem para o zoom não sair
                    constrained: true, // 🔥 Mantém dentro dos limites
                    child: Center(
                      child: Image.memory(
                        controller.capturedImageBytes!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Botão Fechar (X) no canto superior direito
                Positioned(
                  top: 2,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xffe5edfa).withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                // Instrução para zoom (opcional)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "👆 Use dois dedos para dar zoom",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePreview(AnswerSheetController controller) {
    if (controller.isProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Analisando respostas...",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (controller.capturedImage != null) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(controller),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withValues(alpha: 0.05),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagem
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  controller.capturedImageBytes!,
                  fit: BoxFit.contain,
                ),
              ),

              // Overlay com ícone de zoom (indica que é clicável)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        "Ampliar",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildAnswersSection(AnswerSheetController controller) {
    if (controller.extractedAnswers == null) {
      return const SizedBox.shrink();
    }

    final answers = controller.extractedAnswers!;
    final hasManyQuestions =
        answers.length >
        12; // Mostrar barra de scroll se tiver mais de 12 questões

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffe5edfa),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho fixo
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "Respostas detectadas",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (hasManyQuestions) ...[const SizedBox(width: 8)],
                  ],
                ),
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
                              numberOfQuestions: widget.numberOfQuestions,
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
          ),

          // Área rolável das respostas COM barra de scroll visível
          Expanded(
            child: Scrollbar(
              controller: _answersScrollController,
              thumbVisibility: true, // Barra de scroll sempre visível
              trackVisibility: true, // Mostra a trilha da barra
              radius: const Radius.circular(8),
              thickness: 6,
              child: GridView.builder(
                controller: _answersScrollController,
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 110,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.65,
                ),
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final answer = answers[index];
                  final isEdited = controller.editedQuestions[index];
                  return _buildAnswerTile(
                    index: index,
                    answer: answer,
                    isEdited: isEdited,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AnswerSheetController controller) {
    if (controller.extractedAnswers != null) {
      return Row(
        children: [
          // Botão Nova Captura
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Nova captura"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff004aad),
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

  Widget _buildAnswerTile({
    required int index,
    required String? answer,
    required bool isEdited,
  }) {
    final questionNumber = index + 1;
    final formattedNumber = _formatQuestionNumber(questionNumber);

    Color backgroundColor;
    Color borderColor;

    if (isEdited) {
      backgroundColor = Colors.orange[100]!;
      borderColor = Colors.orange;
    } else if (answer == null) {
      backgroundColor = Colors.orange.withValues(alpha: 0.3);
      borderColor = Colors.orange;
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.blueGrey.shade200;
    }

    final displayText = answer == null
        ? "?"
        : answer == "Em branco"
        ? "∅"
        : answer == "Marcação dupla"
        ? "⊜"
        : answer;

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            "$formattedNumber. $displayText",
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  void _confirmAnswers(List<String?> answers) async {
    final confirmationController = AnswerSheetConfirmationController();
    final hasAllAnswers = confirmationController.checkAllAnswers(answers);

    if (hasAllAnswers) {
      final shouldReview = await confirmationController.showSuccessDialog(
        context,
        answers: answers,
        numberOfQuestions: widget.numberOfQuestions,
      );

      if (shouldReview) {
        _navigateToReviewScreen(answers);
      }
    } else {
      await confirmationController.showMissingAnswersDialog(
        context,
        answers: answers,
      );
    }
  }

  void _navigateToReviewScreen(List<String?> answers) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewAnswerSheetScreen(
          studentName: widget.studentName,
          examName: widget.examName,
          answers: answers,
          numberOfQuestions: widget.numberOfQuestions,
        ),
      ),
    );

    // Se finalizou com sucesso, volta para a lista de alunos
    if (result == true && mounted) {
      Navigator.pop(context, true); // Volta para ExamStudentsScreen
    }
  }
}
