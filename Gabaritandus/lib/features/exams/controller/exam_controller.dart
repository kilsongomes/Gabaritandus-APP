// exam_controller.dart
import 'package:flutter/material.dart';
import '../services/exam_service.dart';

class ExamController extends ChangeNotifier {
  final ExamService _service = ExamService();

  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _exams = [];
  List<Map<String, dynamic>> _filteredExams = [];
  Map<String, dynamic>? _currentExam;
  List<Map<String, dynamic>> _examStudents = [];
  String _searchQuery = '';
  int? _teacherGroupId;

  // 🆕 Método para verificar se o controller está inicializado corretamente
  void debugController() {
    print("🔍 [ExamController] Debug:");
    print("   loading: $_loading");
    print("   error: $_error");
    print("   exams count: ${_exams.length}");
    print("   teacherGroupId: $_teacherGroupId");
    print("   service: ${_service != null ? "OK" : "NULL"}");
  }

  // Getters
  bool get loading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get exams => _exams;
  List<Map<String, dynamic>> get filteredExams => _filteredExams;
  Map<String, dynamic>? get currentExam => _currentExam;
  List<Map<String, dynamic>> get examStudents => _examStudents;
  String get searchQuery => _searchQuery;
  int? get teacherGroupId => _teacherGroupId;

  // 🆕 Carregar exames do professor (método público simplificado)
  Future<void> loadTeacherExams() async {
    print("🚀 [ExamController] loadTeacherExams() INICIADO");
    
    // Verificar se já está carregando
    if (_loading) {
      print("⚠️ [ExamController] Já está carregando, ignorando chamada");
      return;
    }
    
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      print("🔄 [ExamController] 1. Buscando group_id do professor...");
      
      // 🆕 SIMPLIFICAR: Usar group_id fixo para teste primeiro
      // Depois que funcionar, voltamos a buscar dinamicamente
      _teacherGroupId = 11; // 🆕 Group ID fixo baseado nos seus logs anteriores
      
      print("🛠️ [ExamController] Usando group_id fixo: $_teacherGroupId");
      
      if (_teacherGroupId == null) {
        _error = "Group ID não encontrado. Você tem turmas atribuídas?";
        print("❌ [ExamController] Group ID é null");
        return;
      }
      
      print("🔄 [ExamController] 2. Buscando exames para group_id: $_teacherGroupId");
      _exams = await _service.getExamsByGroupId(_teacherGroupId!);
      
      print("📊 [ExamController] Recebeu ${_exams.length} exames");
      
      // Ordenar exames por data
      _sortExamsByDate();
      
      // Inicializar lista filtrada
      _filteredExams = List.from(_exams);
      
      print("✅ [ExamController] loadTeacherExams() CONCLUÍDO com sucesso");
      
    } catch (e) {
      _error = "Erro ao carregar exames: ${e.toString()}";
      print("❌ [ExamController] Erro em loadTeacherExams(): $e");
      print("Stack trace: ${e.toString()}");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredExams = List.from(_exams);
    } else {
      _filteredExams = _exams.where((exam) {
        final name = (exam["name"] ?? "").toString().toLowerCase();
        final discipline = (exam["discipline_name"] ?? "").toString().toLowerCase();
        
        return name.contains(_searchQuery) || discipline.contains(_searchQuery);
      }).toList();
    }
  }

  // 🆕 Carregar detalhes de um exame específico
  Future<void> loadExamDetails(String examId) async {
    if (examId.isEmpty) {
      _error = "ID do exame inválido";
      return;
    }
    
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print("🔄 [ExamController] Carregando detalhes do exame: $examId");
      final data = await _service.getExamDetails(examId);
      _currentExam = data["exam"] ?? {};
      _examStudents = List<Map<String, dynamic>>.from(data["users"] ?? []);
      
      print("✅ [ExamController] Detalhes do exame carregados: ${_examStudents.length} alunos");
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = "Erro ao carregar detalhes do exame: $e";
      print("❌ [ExamController] Erro em loadExamDetails: $e");
      notifyListeners();
    }
  }

  // Ordenar exames por data (mais recente primeiro)
  void _sortExamsByDate() {
    try {
      _exams.sort((a, b) {
        final dateAStr = a["createdAt"]?.toString() ?? "";
        final dateBStr = b["createdAt"]?.toString() ?? "";
        
        if (dateAStr.isEmpty || dateBStr.isEmpty) return 0;
        
        final dateA = DateTime.tryParse(dateAStr) ?? DateTime(1900);
        final dateB = DateTime.tryParse(dateBStr) ?? DateTime(1900);
        return dateB.compareTo(dateA); // Descendente
      });
    } catch (e) {
      print("⚠️ [ExamController] Erro ao ordenar exames: $e");
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCurrentExam() {
    _currentExam = null;
    _examStudents = [];
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredExams = List.from(_exams);
    notifyListeners();
  }
}  // Atualizar busca
  