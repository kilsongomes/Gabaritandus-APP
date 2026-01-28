// student_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../classrooms/controllers/classroom_controller.dart';
import '../../../shared/widgets/custom_app_bar.dart'; 

class StudentListScreen extends StatefulWidget {
  final String turma;
  final String escola;
  final int? roomId; // 🆕 ID da turma para buscar alunos

  StudentListScreen({Key? key, required this.turma, required this.escola, this.roomId})
    : super(key: key);

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    
    // Se tiver roomId, carrega os detalhes da turma
    if (widget.roomId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = Provider.of<ClassroomController>(context, listen: false);
        controller.loadClassroomDetails(widget.roomId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar( 
        title: widget.turma, // Título dinâmico com nome da turma
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Text(
              widget.escola,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Cabeçalho da tabela
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "ESTUDANTE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "STATUS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const Divider(),

            // Lista de estudantes REAIS
            Expanded(
              child: _buildStudentsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return Consumer<ClassroomController>(
      builder: (context, controller, _) {
        if (controller.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
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
                  onPressed: () {
                    if (widget.roomId != null) {
                      controller.loadClassroomDetails(widget.roomId!);
                    }
                  },
                  child: const Text("Tentar Novamente"),
                ),
              ],
            ),
          );
        }

        final classroom = controller.currentClassroom;
        if (classroom == null) {
          return const Center(
            child: Text("Nenhum dado da turma carregado"),
          );
        }

        final students = List<Map<String, dynamic>>.from(classroom["room_user"] ?? []);
        
        if (students.isEmpty) {
          return const Center(
            child: Text("Nenhum aluno encontrado na turma"),
          );
        }

        // Filtrar apenas estudantes (role_id = 7)
        final filteredStudents = students.where((student) {
          final roleId = student["role_id"];
          return roleId == 7; // Estudante
        }).toList();

        return ListView.separated(
          itemCount: filteredStudents.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final student = filteredStudents[index];
            return _buildStudentItem(student, classroom);
          },
        );
      },
    );
  }

  Widget _buildStudentItem(Map<String, dynamic> student, Map<String, dynamic> classroom) {
    final studentName = student["user_name"] ?? "Aluno sem nome";
    
    // Buscar disciplinas do aluno
    final studentDisciplines = _getStudentDisciplines(student, classroom);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nome do aluno (leva para student-info)
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/student-info',
                arguments: {
                  "nome": studentName,
                  "turno": _getPeriod(classroom), // Turno 
                  "disciplinas": studentDisciplines, // Disciplinas 
                  "roomId": widget.roomId, // Para futuras integrações
                  "userId": student["user_id"], // Para futuras integrações
                },
              );
            },
            child: Text(
              studentName,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.visible,
            ),
          ),
        ),

        // Botão de upload (ícone cinza)
        IconButton(
          icon: const Icon(
            Icons.cloud_upload,
            color: Colors.grey,
          ),
          onPressed: () {
            // implementar a função de QRCode depois
          },
        ),
      ],
    );
  }

  // 🆕 MÉTODO PARA OBTER O PERÍODO/TURNO
  String _getPeriod(Map<String, dynamic> classroom) {
    final room = classroom["room"] ?? {};
    final periodId = room["period_id"];
    
    // Mapear period_id para nome do turno
    switch (periodId) {
      case 1: return "Manhã";
      case 2: return "Tarde";
      case 3: return "Noite";
      case 4: return "Integral";
      default: return "Manhã";
    }
  }

  // 🆕 MÉTODO PARA OBTER DISCIPLINAS DO ALUNO
  List<Map<String, dynamic>> _getStudentDisciplines(
    Map<String, dynamic> student, 
    Map<String, dynamic> classroom
  ) {
    final roomUserDisciplines = List<Map<String, dynamic>>.from(
      classroom["room_user_discipline"] ?? []
    );
    
    final studentRoomUserId = student["id"];
    
    // Filtrar disciplinas deste aluno específico
    final studentDisciplines = roomUserDisciplines.where((discipline) {
      return discipline["room_user_id"] == studentRoomUserId;
    }).toList();

    // Transformar para o formato esperado pela tela de info
    return studentDisciplines.map((discipline) {
      return {
        "nome": discipline["discipline_name"] ?? "Disciplina não informada",
        "concluidas": 0, // 🆕 Você pode ajustar isso conforme sua lógica
        "total": 16,     // 🆕 Você pode ajustar isso conforme sua lógica
      };
    }).toList();
  }
}