import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/classroom_controller.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../auth/controller/auth_controller.dart';

class ClassroomListScreen extends StatefulWidget {
  const ClassroomListScreen({super.key});

  @override
  State<ClassroomListScreen> createState() => _ClassroomListScreenState();
}

class _ClassroomListScreenState extends State<ClassroomListScreen> {
  final TextEditingController _searchController = TextEditingController(); 
  final FocusNode _searchFocusNode = FocusNode(); 
  @override
  void initState() {
    super.initState();
    // Carregar turmas quando a tela for aberta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ClassroomController>(
        context,
        listen: false,
      );
      controller.loadUserClassrooms();
    });

      //LISTENER PARA ATUALIZAR FILTRO ENQUANTO DIGITA
     _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // MÉTODO PARA ATUALIZAR FILTRO
  void _onSearchChanged() {
    final controller = Provider.of<ClassroomController>(context, listen: false);
    controller.setSearchQuery(_searchController.text);
  }

  // MÉTODO PARA LIMPAR BUSCA
  void _clearSearch() {
    _searchController.clear();
    final controller = Provider.of<ClassroomController>(context, listen: false);
    controller.clearSearch();
    // Manter o foco na busca após limpar
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Turmas", showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil
            _buildProfileSection(),
            const SizedBox(height: 16),

            // Campo de pesquisa
            _buildSearchField(),
            const SizedBox(height: 16),

            Consumer<ClassroomController>(
              builder: (context, controller, _) {
                final total = controller.classrooms.length;
                final showing = controller.filteredClassrooms.length;
                final hasSearch = controller.searchQuery.isNotEmpty;
                
                if (total == 0) return const SizedBox();
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    hasSearch
                        ? "Mostrando $showing de $total turmas"
                        : "Total: $total turmas",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),

            // Lista de turmas
            _buildClassroomsList(),
          ],
        ),
      ),
    );
  }

   Widget _buildSearchField() {
    return Consumer<ClassroomController>(
      builder: (context, controller, _) {
        return TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: "Buscar turma ou escola...",
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
          onChanged: (value) {
            // Atualização já feita pelo listener
          },
        );
      },
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final userName = authController.userName ?? "Usuário";
        final userRole = authController.userRole ?? "Professor";
        final userPhoto = authController.userPhoto;

        return Row(
          children: [
            _buildUserAvatar(userName, userPhoto), // MÉTODO SEPARADO
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userRole,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserAvatar(String userName, String? userPhoto) {
    if (userPhoto != null && userPhoto.isNotEmpty) {
      return CircleAvatar(radius: 25, backgroundImage: NetworkImage(userPhoto));
    } else {
      // Codificar o nome para URL
      final encodedName = Uri.encodeComponent(userName);
      return CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(
          "https://ui-avatars.com/api/?name=$encodedName&background=00B4D8&color=fff&size=128",
        ),
      );
    }
  }

  Widget _buildClassroomsList() {
    return Consumer<ClassroomController>(
      builder: (context, controller, _) {
        // 🆕 USAR filteredClassrooms EM VEZ DE classrooms
        final classrooms = controller.filteredClassrooms;
        
        if (controller.loading) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.error != null) {
          return Expanded(
            child: Center(
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
                    onPressed: () {
                      controller.loadUserClassrooms();
                    },
                    child: const Text("Tentar Novamente"),
                  ),
                ],
              ),
            ),
          );
        }

        if (classrooms.isEmpty) {
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (controller.searchQuery.isNotEmpty) ...[
                    const Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Nenhuma turma encontrada",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Não encontramos turmas com '${controller.searchQuery}'",
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
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Nenhuma turma encontrada",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Você não possui turmas atribuídas",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho tabela (mantido)
              const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        "TURMA",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        "ESCOLA",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),

              // Lista de turmas FILTRADA
              Expanded(
                child: ListView.separated(
                  itemCount: classrooms.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final classroom = classrooms[index];
                    return _buildClassroomItem(classroom);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClassroomItem(Map<String, dynamic> classroom) {
    // Usando os campos reais da API
    final turma = classroom["name"] ?? "Turma não informada";
    final escola = classroom["school_name"] ?? "Escola não informada";
    final roomId = classroom["id"];

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/student-list',
          arguments: {
            "turma": turma,
            "escola": escola,
            "roomId": roomId, // 🆕 Passando o ID da turma
          },
        );
      },
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                turma,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                escola,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
