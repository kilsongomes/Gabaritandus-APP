// exam_controller.dart - SIMPLIFICAR
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

  // Getters
  bool get loading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get exams => _exams;
  List<Map<String, dynamic>> get filteredExams => _filteredExams;
  Map<String, dynamic>? get currentExam => _currentExam;
  List<Map<String, dynamic>> get examStudents => _examStudents;
  String get searchQuery => _searchQuery;

  Future<void> loadTeacherExams() async {
    print("🚀 [ExamController] loadTeacherExams() INICIADO");
    
    if (_loading) {
      print("⚠️ [ExamController] Já está carregando");
      return;
    }
    
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      print("🔄 [ExamController] Buscando exames do professor...");
      _exams = await _service.getTeacherExams();
      
      print("📊 [ExamController] ${_exams.length} exames recebidos");
      
      // Ordenar por data (mais recente primeiro)
      _sortExamsByDate();
      
      // Inicializar lista filtrada
      _filteredExams = List.from(_exams);
      
      print("✅ [ExamController] Exames carregados com sucesso");
      
    } catch (e) {
      _error = "Erro ao carregar exames: ${e.toString()}";
      print("❌ [ExamController] Erro: $e");
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

  Future<void> loadExamDetails(String examId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print("🔄 [ExamController] Carregando detalhes do exame: $examId");
      final data = await _service.getExamDetails(examId);
      _currentExam = data["exam"] ?? {};
      _examStudents = List<Map<String, dynamic>>.from(data["users"] ?? []);
      
      print("✅ [ExamController] Detalhes carregados: ${_examStudents.length} alunos");
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = "Erro ao carregar detalhes: $e";
      print("❌ [ExamController] Erro em loadExamDetails: $e");
      notifyListeners();
    }
  }

  void _sortExamsByDate() {
    try {
      _exams.sort((a, b) {
        final dateAStr = a["createdAt"]?.toString() ?? "";
        final dateBStr = b["createdAt"]?.toString() ?? "";
        
        if (dateAStr.isEmpty || dateBStr.isEmpty) return 0;
        
        final dateA = DateTime.tryParse(dateAStr) ?? DateTime(1900);
        final dateB = DateTime.tryParse(dateBStr) ?? DateTime(1900);
        return dateB.compareTo(dateA);
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
}