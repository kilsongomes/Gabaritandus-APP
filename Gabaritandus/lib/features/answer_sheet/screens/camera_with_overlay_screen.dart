import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:scanner_overlay/scanner_overlay.dart';

class CameraWithOverlayScreen extends StatefulWidget {
  final String studentName;
  final String examName;
  final dynamic studentId;
  final String examId;
  final int numberOfQuestions;

  const CameraWithOverlayScreen({
    super.key,
    required this.studentName,
    required this.examName,
    required this.studentId,
    required this.examId,
    required this.numberOfQuestions,

  });

  @override
  State<CameraWithOverlayScreen> createState() => _CameraWithOverlayScreenState();
}

class _CameraWithOverlayScreenState extends State<CameraWithOverlayScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  


  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print("❌ Erro ao inicializar câmera: $e");
    }
  }

  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized) return;

    try {
      final XFile picture = await _cameraController!.takePicture();
      
      if (!mounted) return;
      
      Navigator.pop(context, picture);
      
    } catch (e) {
      print("❌ Erro ao tirar foto: $e");
    }
  }


  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                // Câmera ocupando toda a tela
                CameraPreview(_cameraController!),
                
                // 🔥 APENAS OVERLAY CENTRALIZADO
                Center(
                  child: ScannerOverlay(
                    height: 650,
                    width: 500,
                    borderColor: Colors.blueAccent,
                    borderRadius: 2,
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      
      // Botão flutuante para capturar
      floatingActionButton: _isCameraInitialized
          ? FloatingActionButton(
              onPressed: _takePicture,
              backgroundColor: const Color(0xff004aad),
              child: const Icon(Icons.camera),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}