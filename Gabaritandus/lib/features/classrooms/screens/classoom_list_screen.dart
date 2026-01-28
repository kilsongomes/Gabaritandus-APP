import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/classroom_controller.dart';
import '../../../shared/widgets/custom_app_bar.dart'; 

class OpenQuestionScreen extends StatefulWidget {
  const OpenQuestionScreen({super.key});

  @override
  State<OpenQuestionScreen> createState() => _OpenQuestionScreenState();
}

class _OpenQuestionScreenState extends State<OpenQuestionScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar turmas quando a tela for aberta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ClassroomController>(context, listen: false);
      controller.loadUserClassrooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar( 
        title: "Turmas",
        showBackButton: true,
      ),
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
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(
            "https://static.wikia.nocookie.net/dublagem/images/d/d2/Raposo.jpg/revision/latest/thumbnail/width/360/height/360?cb=20240405221148&path-prefix=pt-br",
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Alex Raposo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              "Professor",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildClassroomsList() {
    return Consumer<ClassroomController>(
      builder: (context, controller, _) {
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