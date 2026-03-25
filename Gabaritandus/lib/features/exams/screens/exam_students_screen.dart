import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/exam_controller.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../answer_sheet/screens/capture_answer_sheet_screen.dart';

class ExamStudentsScreen extends StatefulWidget {
  final String examId;
  final String examName;
  final int groupId;
  final String examGrade;
  final String disciplineName;

  const ExamStudentsScreen({
    super.key,
    required this.examId,
    required this.examName,
    required this.groupId,
    required this.examGrade,
    required this.disciplineName,
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

  void _navigateToCaptureScreen(String studentName, dynamic studentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaptureAnswerSheetScreen(
          studentName: studentName,
          examName: widget.examName,
          studentId: studentId,
          examId: widget.examId,
          examGrade: widget.examGrade,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.disciplineName, showBackButton: true),
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${exam["grade_name"] ?? "Não informado"}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${(exam["questions"] as List?)?.length ?? 0} questões",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
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

            // Contador de estudantes
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
                      "Carregando estudantes...",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _searchQuery.isEmpty
                        ? "Total: $total estudante${total != 1 ? 's' : ''}"
                        : "Mostrando $showing de $total estudante${total != 1 ? 's' : ''}",
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
                    "Estudante",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    "Ação",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const Divider(),

            // Lista de estudantes
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
        hintText: "Pesquise por estudante",
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
          borderSide: const BorderSide(color: Color(0xff004aad), width: 2),
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
                  "Carregando estudantes...",
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
                  "Erro ao carregar estudantes",
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
                    backgroundColor: const Color(0xff004aad),
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
                    "Nenhum estudante encontrado",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Não encontramos estudantes com '$_searchQuery'",
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
                    "Nenhum estudante encontrado",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Este exame não tem estudantes atribuídos",
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

    final studentName = user["name"] ?? "Estudante sem nome";
    final studentId = user["id"];
    final hasApplication = applications.isNotEmpty;
    final studentUsername = user["username"] ?? "";

    // Determinar status baseado nas applications e results
    String status = "Não iniciou";
    Color statusColor = Colors.grey;

    String scoreText = "";

    if (hasApplication) {
      // Ordenar por try_number (maior primeiro)
      applications.sort(
        (a, b) => (b["try_number"] ?? 0).compareTo(a["try_number"] ?? 0),
      );
      final lastApplication = applications.first;

      final appEnd = lastApplication["app_end"];

      if (appEnd != null) {
        // Exame foi finalizado
        status = "Concluído";
        statusColor = Colors.green;

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
          }
        }
      } else {
        // Exame em andamento
        status = "Em andamento";
        statusColor = Colors.orange;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações do estudante
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (studentUsername.isNotEmpty)
                        Tooltip(
                          message: studentUsername,
                          child: Text(
                            "$studentUsername",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
                    fontSize: 9,
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
            icon: Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 24,),
            onPressed: () {
              _navigateToCaptureScreen(studentName, studentId);
            },
          ),
        ],
      ),
    );
  }
}
