// exam_students_screen.dart - ADICIONAR ESTE ARQUIVO
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/exam_controller.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class ExamStudentsScreen extends StatefulWidget {
  final String examId;
  final String examName;
  final int groupId;

  const ExamStudentsScreen({
    super.key,
    required this.examId,
    required this.examName,
    required this.groupId,
  });

  @override
  State<ExamStudentsScreen> createState() => _ExamStudentsScreenState();
}

class _ExamStudentsScreenState extends State<ExamStudentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ExamController>(context, listen: false);
      controller.loadExamDetails(widget.examId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.examName,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do exame
            Consumer<ExamController>(
              builder: (context, controller, _) {
                final exam = controller.currentExam;
                if (exam == null) return const SizedBox();
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam["name"] ?? "Exame",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Disciplina: ${exam["discipline_name"] ?? "Não informada"}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "Ano: ${exam["grade_name"] ?? "Não informado"}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "Questões: ${(exam["questions"] as List?)?.length ?? 0}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Cabeçalho da lista
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ALUNO",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "STATUS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),
            
            // Lista de alunos
            Expanded(child: _buildStudentsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return Consumer<ExamController>(
      builder: (context, controller, _) {
        if (controller.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Erro: ${controller.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadExamDetails(widget.examId),
                  child: const Text("Tentar Novamente"),
                ),
              ],
            ),
          );
        }

        final students = controller.examStudents;
        
        if (students.isEmpty) {
          return const Center(
            child: Text("Nenhum aluno encontrado para este exame"),
          );
        }

        return ListView.separated(
          itemCount: students.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final studentData = students[index];
            final user = studentData["user"] ?? {};
            final applications = studentData["applications"] ?? [];
            final results = studentData["results"] ?? [];
            
            return _buildStudentItem(user, applications, results);
          },
        );
      },
    );
  }

  Widget _buildStudentItem(
    Map<String, dynamic> user,
    List<dynamic> applications,
    List<dynamic> results,
  ) {
    final studentName = user["name"] ?? "Aluno sem nome";
    final studentId = user["id"];
    final hasApplication = applications.isNotEmpty;
    final hasResult = results.isNotEmpty;
    
    // Determinar status
    String status = "Não iniciou";
    Color statusColor = Colors.grey;
    
    if (hasApplication) {
      final application = applications.first;
      final appEnd = application["app_end"];
      
      if (appEnd != null) {
        status = "Concluído";
        statusColor = Colors.green;
        
        if (hasResult) {
          final result = results.first;
          final score = result["score"] ?? 0;
          status = "Nota: $score";
        }
      } else {
        status = "Em andamento";
        statusColor = Colors.orange;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nome do aluno
        Expanded(
          child: Text(
            studentName,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
          ),
        ),
        
        // 🆕 Botão para capturar gabarito
        IconButton(
          icon: Icon(
            hasApplication ? Icons.camera_alt : Icons.camera_alt_outlined,
            color: hasApplication ? Color(0xFF00B4D8) : Colors.grey,
          ),
          onPressed: () {
            // 🆕 Navegar para tela de captura de gabarito
            Navigator.pushNamed(
              context,
              '/capture-answer-sheet',
              arguments: {
                "studentId": studentId,
                "studentName": studentName,
                "examId": widget.examId,
                "examName": widget.examName,
                "hasApplication": hasApplication,
              },
            );
          },
        ),
      ],
    );
  }
}