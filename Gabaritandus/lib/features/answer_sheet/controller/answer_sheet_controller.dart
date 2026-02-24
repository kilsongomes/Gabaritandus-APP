import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gabaritandus/features/answer_sheet/services/answer_sheet_reader.dart';

class AnswerSheetController extends ChangeNotifier {
  final AnswerSheetProcessor _reader = AnswerSheetProcessor();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isProcessing = false;
  String? _error;
  List<String?>? _extractedAnswers;
  XFile? _capturedImage;
  
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  List<String?>? get extractedAnswers => _extractedAnswers;
  XFile? get capturedImage => _capturedImage;
  
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
  
  /// Limpar os dados
  void clear() {
    _capturedImage = null;
    _extractedAnswers = null;
    _error = null;
    notifyListeners();
  }
}