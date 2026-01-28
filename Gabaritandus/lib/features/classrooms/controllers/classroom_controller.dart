import 'package:flutter/material.dart';
import '../services/classroom_service.dart';

class ClassroomController extends ChangeNotifier {
  final ClassroomService _service = ClassroomService();
  
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _classrooms = [];
  Map<String, dynamic>? _currentClassroom;

  // Getters
  bool get loading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get classrooms => _classrooms;
  Map<String, dynamic>? get currentClassroom => _currentClassroom;

  Future<void> loadUserClassrooms() async {
    _loading = true;
  _error = null;
  notifyListeners();

  try {
    _classrooms = await _service.getUserClassrooms();
    
    // ORDENAR TURMAS EM ORDEM ALFABÉTICA
    _sortClassroomsAlphabetically();
    
    _loading = false;
    notifyListeners();
  } catch (e) {
    _loading = false;
    _error = "Erro ao carregar turmas: $e";
    notifyListeners();
  }
}

  // 🆕 MÉTODO PARA CARREGAR DETALHES DE UMA TURMA
  Future<void> loadClassroomDetails(int roomId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _currentClassroom = await _service.getClassroomDetails(roomId);
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = "Erro ao carregar detalhes da turma: $e";
      notifyListeners();
    }
  }

  void _sortClassroomsAlphabetically() {
  _classrooms.sort((a, b) {
    // Pega o nome da turma, com fallback para string vazia
    final nameA = (a["name"] ?? "").toString().toLowerCase();
    final nameB = (b["name"] ?? "").toString().toLowerCase();
    
    // Ordena por nome da turma
    return nameA.compareTo(nameB);
  });
}

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCurrentClassroom() {
    _currentClassroom = null;
    notifyListeners();
  }
}