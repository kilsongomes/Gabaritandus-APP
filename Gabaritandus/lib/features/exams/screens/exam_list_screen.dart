import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/exam_controller.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../auth/controller/auth_controller.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
void initState() {
  super.initState();
  print("🔵 [ExamListScreen] initState chamado");
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    print("🔵 [ExamListScreen] addPostFrameCallback executado");
    try {
      final controller = Provider.of<ExamController>(context, listen: false);
      print("🔵 [ExamListScreen] Controller obtido, chamando loadTeacherExams...");
      controller.loadTeacherExams();
    } catch (e) {
      print("❌ [ExamListScreen] Erro ao iniciar controller: $e");
    }
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
    final controller = Provider.of<ExamController>(context, listen: false);
    controller.setSearchQuery(_searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    final controller = Provider.of<ExamController>(context, listen: false);
    controller.clearSearch();
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Meus Exames", showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             // Seção de perfil do usuário
            _buildProfileSection(),
            const SizedBox(height: 20),
            // Campo de pesquisa
            _buildSearchField(),
            const SizedBox(height: 16),

            // Contador
            Consumer<ExamController>(
              builder: (context, controller, _) {
                final total = controller.exams.length;
                final showing = controller.filteredExams.length;
                final hasSearch = controller.searchQuery.isNotEmpty;

                if (total == 0) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    hasSearch
                        ? "Mostrando $showing de $total exames"
                        : "Total: $total exames",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                );
              },
            ),

            // Lista de exames
            Expanded(child: _buildExamsList()),
          ],
        ),
      ),
    );
  }

  // Método para construir a seção de perfil
  Widget _buildProfileSection() {
  return Consumer<AuthController>(
    builder: (context, authController, _) {
      final userName = authController.userName ?? "Usuário";
      final userRole = authController.userRole ?? "Professor";
      final userPhoto = authController.userPhoto;

      return Row(
        children: [
          // Avatar do usuário (fixo)
          _buildUserAvatar(userName, userPhoto),
          const SizedBox(width: 12),
          
          // 🔥 CORREÇÃO: Expanded para o texto não vazar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 2, // Permite até 2 linhas
                  overflow: TextOverflow.ellipsis, // Adiciona ... se necessário
                ),
                const SizedBox(height: 2),
                Text(
                  userRole,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

  Widget _buildUserAvatar(String userName, String? userPhoto) {
    if (userPhoto != null && userPhoto.isNotEmpty) {
      // Se o usuário tem foto, mostrar foto
      return CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(userPhoto),
      );
    } else {
      // Se não tem foto, mostrar iniciais com cor de fundo
      final initials = _getInitials(userName);
      
      return CircleAvatar(
        radius: 25,
        backgroundColor: const Color(0xFF00B4D8), // Cor azul do app
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  // Método para extrair iniciais do nome
  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    
    final nameParts = name.trim().split(' ');
    
    if (nameParts.length == 1) {
      // Se tem apenas uma palavra, pega as primeiras 2 letras
      return nameParts[0].length >= 2 
          ? nameParts[0].substring(0, 2).toUpperCase()
          : nameParts[0].toUpperCase();
    } else {
      // Se tem múltiplas palavras, pega a primeira letra de cada (máx 2)
      final firstInitial = nameParts[0].isNotEmpty 
          ? nameParts[0][0].toUpperCase() 
          : '';
      
      final secondInitial = nameParts.length > 1 && nameParts[1].isNotEmpty
          ? nameParts[1][0].toUpperCase()
          : '';
      
      return '$firstInitial$secondInitial';
    }
  }

  Widget _buildSearchField() {
    return Consumer<ExamController>(
      builder: (context, controller, _) {
        return TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: "Buscar exame por nome ou disciplina...",
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: controller.searchQuery.isNotEmpty
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
      },
    );
  }

  Widget _buildExamsList() {
    return Consumer<ExamController>(
      builder: (context, controller, _) {
        final exams = controller.filteredExams;

        if (controller.loading && exams.isEmpty) {
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
                  onPressed: () => controller.loadTeacherExams(),
                  child: const Text("Tentar Novamente"),
                ),
              ],
            ),
          );
        }

        if (exams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.searchQuery.isNotEmpty) ...[
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Nenhum exame encontrado",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Não encontramos exames com '${controller.searchQuery}'",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _clearSearch,
                    child: const Text("Limpar busca"),
                  ),
                ] else ...[
                  const Icon(Icons.assignment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Nenhum exame encontrado",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Você não possui exames cadastrados",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: exams.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final exam = exams[index];
            return _buildExamItem(exam);
          },
        );
      },
    );
  }

  Widget _buildExamItem(Map<String, dynamic> exam) {
    final examName = exam["name"] ?? "Exame sem nome";
    final discipline = exam["discipline_name"] ?? "Disciplina não informada";
    final grade = exam["grade_name"] ?? "Ano não informado";
    final status = exam["status"] ?? "unknown";
    final createdAt = exam["createdAt"];

    // Formatar data
    String formattedDate = "Data não informada";
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate = "${date.day}/${date.month}/${date.year}";
      } catch (e) {
        formattedDate = createdAt.toString();
      }
    }

    // Cor do status
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    switch (status) {
      case "active":
        statusColor = Colors.green;
        statusIcon = Icons.play_circle_filled;
        break;
      case "finished":
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case "pending":
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          examName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("$discipline • $grade"),
            Text(
              "Criado: $formattedDate",
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF00B4D8)),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/exam-students',
            arguments: {
              "examId": exam["id"]?.toString() ?? "",
              "examName": examName,
              "groupId": exam["group_id"] ?? 0,
            },
          );
        },
      ),
    );
  }
}
