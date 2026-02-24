import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/exam_controller.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../answer_sheet/screens/capture_answer_sheet_screen.dart';

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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _filteredStudents = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ExamController>(context, listen: false);
      controller.loadExamDetails(widget.examId);
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterStudents();
    });
  }

  void _filterStudents() {
    final controller = Provider.of<ExamController>(context, listen: false);
    final students = controller.examStudents;

    if (_searchQuery.isEmpty) {
      _filteredStudents = List.from(students);
    } else {
      _filteredStudents = students.where((studentData) {
        final user = studentData["user"] ?? {};
        final studentName = (user["name"] ?? "").toString().toLowerCase();
        final studentEmail = (user["email"] ?? "").toString().toLowerCase();

        return studentName.contains(_searchQuery) ||
            studentEmail.contains(_searchQuery);
      }).toList();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
    setState(() {
      _searchQuery = '';
    });
  }

  // Método para formatar duração
  String _formatDuration(int? seconds) {
    if (seconds == null) return "Não informada";

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return "$hours h ${minutes.toString().padLeft(2, '0')} min";
    } else {
      return "$minutes min";
    }
  }

  // Método para formatar data
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Não informada";

    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.examName, showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do exame
            Consumer<ExamController>(
              builder: (context, controller, _) {
                final exam = controller.currentExam;
                if (exam == null || controller.loading) {
                  return const SizedBox();
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        Row(
                          children: [
                            Icon(Icons.book, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Disciplina: ${exam["discipline_name"] ?? "Não informada"}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Ano: ${exam["grade_name"] ?? "Não informado"}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.question_answer,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Questões: ${(exam["questions"] as List?)?.length ?? 0}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Duração: ${_formatDuration(exam["duration_in_seconds"])}",
                                style: TextStyle(color: Colors.grey[600]),
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

            const SizedBox(height: 16),

            // Campo de busca
            _buildSearchField(),

            const SizedBox(height: 16),

            // Contador de alunos
            Consumer<ExamController>(
              builder: (context, controller, _) {
                final total = controller.examStudents.length;
                final showing = _searchQuery.isEmpty
                    ? total
                    : _filteredStudents.length;

                if (total == 0 && !controller.loading) return const SizedBox();

                if (controller.loading) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Carregando alunos...",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _searchQuery.isEmpty
                        ? "Total: $total aluno${total != 1 ? 's' : ''}"
                        : "Mostrando $showing de $total aluno${total != 1 ? 's' : ''}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                );
              },
            ),

            // Cabeçalho da lista
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "ALUNO",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "STATUS",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 48), // Espaço para o botão de upload
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: "Buscar aluno por nome...",
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _clearSearch,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00B4D8), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildStudentsList() {
    return Consumer<ExamController>(
      builder: (context, controller, _) {
        if (controller.loading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "Carregando alunos...",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (controller.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  "Erro ao carregar alunos",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    controller.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.loadExamDetails(widget.examId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4D8),
                  ),
                  child: const Text(
                    "Tentar Novamente",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final students = _searchQuery.isEmpty
            ? controller.examStudents
            : _filteredStudents;

        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_searchQuery.isNotEmpty) ...[
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Nenhum aluno encontrado",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Não encontramos alunos com '$_searchQuery'",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _clearSearch,
                    child: const Text("Limpar busca"),
                  ),
                ] else ...[
                  const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Nenhum aluno encontrado",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Este exame não tem alunos atribuídos",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: students.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final studentData = students[index];
            return _buildStudentItem(studentData);
          },
        );
      },
    );
  }

  Widget _buildStudentItem(Map<String, dynamic> studentData) {
    final user = studentData["user"] ?? {};
    final applications = List<Map<String, dynamic>>.from(
      studentData["applications"] ?? [],
    );
    final results = List<Map<String, dynamic>>.from(
      studentData["results"] ?? [],
    );

    final studentName = user["name"] ?? "Aluno sem nome";
    final studentEmail = user["email"] ?? "";
    final studentId = user["id"];
    final hasApplication = applications.isNotEmpty;

    // Determinar status baseado nas applications e results
    String status = "Não iniciou";
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.pending;
    String scoreText = "";
    int tryCount = 0;
    String lastAttemptDate = "";

    if (hasApplication) {
      // Ordenar por try_number (maior primeiro)
      applications.sort(
        (a, b) => (b["try_number"] ?? 0).compareTo(a["try_number"] ?? 0),
      );
      final lastApplication = applications.first;

      tryCount = applications.length;
      lastAttemptDate = _formatDate(lastApplication["app_start"]?.toString());

      final appEnd = lastApplication["app_end"];

      if (appEnd != null) {
        // Exame foi finalizado
        status = "Concluído";
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;

        // Verificar se tem resultado
        if (results.isNotEmpty) {
          // Encontrar o resultado correspondente à última application
          final lastResult = results.firstWhere(
            (result) => result["application_id"] == lastApplication["id"],
            orElse: () => {},
          );

          if (lastResult.isNotEmpty) {
            final score = lastResult["score"] ?? 0;
            scoreText = "Nota: $score";
            status = "Corrigido";
            statusColor = Colors.blue;
            statusIcon = Icons.grade;
          }
        }
      } else {
        // Exame em andamento
        status = "Em andamento";
        statusColor = Colors.orange;
        statusIcon = Icons.timer;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações do aluno
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Tooltip(
                        message: studentName, // Mostra nome completo ao segurar
                        child: Text(
                          studentName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (studentEmail.isNotEmpty)
                        Tooltip(
                          message: studentEmail,
                          child: Text(
                            studentEmail,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      if (tryCount > 0)
                        Text(
                          "Tentativas: $tryCount${lastAttemptDate.isNotEmpty ? ' • Última: $lastAttemptDate' : ''}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      if (scoreText.isNotEmpty)
                        Text(
                          scoreText,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ),
          ),

          // Botão para capturar gabarito
          IconButton(
            icon: Icon(
              hasApplication ? Icons.camera_alt : Icons.camera_alt_outlined,
              color: hasApplication ? const Color(0xFF00B4D8) : Colors.grey,
              size: 24,
            ),
            onPressed: () {
              _showCaptureOptions(context, studentName, studentId);
            },
          ),
        ],
      ),
    );
  }

  //  Método para mostrar opções de captura
  void _showCaptureOptions(
    BuildContext context,
    String studentName,
    dynamic studentId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Capturar gabarito",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  studentName,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Opção 1: Tirar foto
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt, size: 24),
                    label: const Text(
                      "Tirar foto do gabarito",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // 🔥 ATUALIZADO: Navegar para tela de captura
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CaptureAnswerSheetScreen(
                            studentName: studentName,
                            examName: widget.examName,
                            studentId: studentId,
                            examId: widget.examId,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Opção 2: Escolher da galeria
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library, size: 24),
                    label: const Text(
                      "Escolher da galeria",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00B4D8),
                      side: const BorderSide(color: Color(0xFF00B4D8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // 🔥 ATUALIZADO: Navegar para tela de captura
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CaptureAnswerSheetScreen(
                            studentName: studentName,
                            examName: widget.examName,
                            studentId: studentId,
                            examId: widget.examId,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _captureFromCamera(String studentName, dynamic studentId) {
    // TODO: Implementar captura de foto com câmera
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Abrir câmera para capturar gabarito de $studentName"),
        duration: const Duration(seconds: 2),
      ),
    );

    // Para implementar, você precisará adicionar:
    // 1. Dependência: image_picker: ^1.0.4
    // 2. Permissões de câmera no AndroidManifest.xml e Info.plist
    // 3. Código como:
    //    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    //    if (image != null) {
    //      // Processar imagem
    //    }
  }

  void _pickFromGallery(String studentName, dynamic studentId) {
    // TODO: Implementar seleção da galeria
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Abrir galeria para selecionar gabarito de $studentName"),
        duration: const Duration(seconds: 2),
      ),
    );

    // Para implementar, você precisará adicionar:
    // 1. Dependência: image_picker: ^1.0.4
    // 2. Código como:
    //    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    //    if (image != null) {
    //      // Processar imagem
    //    }
  }
}
