import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gabaritandus/features/answer_sheet/services/answer_sheet_reader.dart';
import '../screens/camera_with_overlay_screen.dart';

class AnswerSheetController extends ChangeNotifier {
  final AnswerSheetProcessor _reader = AnswerSheetProcessor();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isProcessing = false;
  String? _error;
  List<String?>? _extractedAnswers;
  XFile? _capturedImage;

  String? _currentStudentName;
  String? _currentExamName;
  dynamic _currentStudentId;
  String? _currentExamId;

  bool get isProcessing => _isProcessing;
  String? get error => _error;
  List<String?>? get extractedAnswers => _extractedAnswers;
  XFile? get capturedImage => _capturedImage;

  String? get currentStudentName => _currentStudentName;
  String? get currentExamName => _currentExamName;
  dynamic get currentStudentId => _currentStudentId;
  String? get currentExamId => _currentExamId;

  List<bool> _editedQuestions = List.filled(10, false);
  List<bool> get editedQuestions => _editedQuestions;

  Future<void> captureWithOverlay(
    BuildContext context, {
    required String studentName,
    required String examName,
    required dynamic studentId,
    required String examId,
  }) async {
    // Salvar informações do contexto atual
    _currentStudentName = studentName;
    _currentExamName = examName;
    _currentStudentId = studentId;
    _currentExamId = examId;

    try {
      print("📷 [AnswerSheetController] Abrindo câmera com overlay...");

      // Navegar para tela de câmera com overlay e aguardar resultado
      final XFile? image = await Navigator.push<XFile>(
        context,
        MaterialPageRoute(
          builder: (context) => CameraWithOverlayScreen(
            studentName: studentName,
            examName: examName,
            studentId: studentId,
            examId: examId,
          ),
        ),
      );

      if (image != null) {
        _capturedImage = image;
        await _processImage(image);
      }
    } catch (e) {
      _error = "Erro ao capturar imagem: $e";
      print("❌ [AnswerSheetController] $e");
      notifyListeners();
    }
  }

  /// Capturar imagem da câmera
  Future<void> captureFromCamera() async {
    try {
      print("📷 [AnswerSheetController] Abrindo câmera...");

      _error = null;
      notifyListeners();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _capturedImage = image;
        await _processImage(image);
      }
    } catch (e) {
      _error = "Erro ao capturar imagem: $e";
      print("❌ [AnswerSheetController] $e");
      notifyListeners();
    }
  }

  /// Selecionar imagem da galeria
  Future<void> pickFromGallery() async {
    try {
      print("🖼️ [AnswerSheetController] Abrindo galeria...");

      _error = null;
      notifyListeners();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _capturedImage = image;
        await _processImage(image);
      }
    } catch (e) {
      _error = "Erro ao selecionar imagem: $e";
      print("❌ [AnswerSheetController] $e");
      notifyListeners();
    }
  }

  /// Processar a imagem selecionada
  Future<void> _processImage(XFile image) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      print("⚙️ [AnswerSheetController] Processando imagem...");

      // Converter XFile para File
      final File imageFile = File(image.path);

      // Processar com o reader
      _extractedAnswers = await _reader.processAnswerSheet(imageFile);

      print("✅ [AnswerSheetController] Processamento concluído");
      print("   Respostas detectadas: $_extractedAnswers");
    } catch (e) {
      _error = "Erro ao processar imagem: $e";
      print("❌ [AnswerSheetController] $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void updateExtractedAnswers(List<String?> updatedAnswers) {
    // Identificar quais questões foram editadas
    for (int i = 0; i < updatedAnswers.length; i++) {
      if (_extractedAnswers != null && 
          i < _extractedAnswers!.length && 
          _extractedAnswers![i] != updatedAnswers[i]) {
        _editedQuestions[i] = true;
      }
    }
    
    _extractedAnswers = updatedAnswers;
    notifyListeners();
    print("✏️ [AnswerSheetController] Respostas atualizadas: $_extractedAnswers");
    print("✏️ Questões editadas: $_editedQuestions");
  }
  
  // Resetar flags de edição (quando fizer nova captura)
  void resetEditedFlags() {
    _editedQuestions = List.filled(10, false);
  }
  
  // Modificar o método clear para também resetar as flags
  void clear() {
    _capturedImage = null;
    _extractedAnswers = null;
    _error = null;
    _editedQuestions = List.filled(10, false); // Resetar flags
    notifyListeners();
  }  
}
