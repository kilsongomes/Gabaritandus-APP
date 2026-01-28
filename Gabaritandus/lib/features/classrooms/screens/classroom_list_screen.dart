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
            TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de turmas
            _buildClassroomsList(),
          ],
        ),
      ),
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
            _buildUserAvatar(userName, userPhoto), // ✅ MÉTODO SEPARADO
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
        if (controller.loading) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
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

        if (controller.classrooms.isEmpty) {
          return const Expanded(
            child: Center(
              child: Text(
                "Nenhuma turma encontrada",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho tabela
              Row(
                children: const [
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

              // Lista de turmas
              Expanded(
                child: ListView.separated(
                  itemCount: controller.classrooms.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final classroom = controller.classrooms[index];
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
