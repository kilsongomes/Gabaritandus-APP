import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
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
  State<CameraWithOverlayScreen> createState() =>
      _CameraWithOverlayScreenState();
}

class _CameraWithOverlayScreenState extends State<CameraWithOverlayScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      _initializeCamera();
    }
  }

  // ==========================
  // 📸 MOBILE (Android/iOS)
  // ==========================
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

  Future<void> _takePictureMobile() async {
    if (!_cameraController!.value.isInitialized) return;

    try {
      final XFile picture = await _cameraController!.takePicture();

      if (!mounted) return;

      Navigator.pop(context, picture);
    } catch (e) {
      print("❌ Erro ao tirar foto: $e");
    }
  }

  // ==========================
  // 🌐 WEB (Navegador)
  // ==========================
  Future<void> _pickImageWeb() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image == null) return;

      if (!mounted) return;

      Navigator.pop(context, image);
    } catch (e) {
      print("❌ Erro ao selecionar imagem: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // ==========================
  // 🎨 UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: kIsWeb
          ? _buildWebView()
          : _isCameraInitialized
          ? _buildCameraView()
          : const Center(child: CircularProgressIndicator()),

      floatingActionButton: FloatingActionButton(
        onPressed: kIsWeb ? _pickImageWeb : _takePictureMobile,
        backgroundColor: const Color(0xff004aad),
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCameraView() {
    return Stack(
      fit: StackFit.expand,
      children: [CameraPreview(_cameraController!), _buildOverlay()],
    );
  }

  Widget _buildWebView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: const Center(
            child: Text(
              "📷 Clique no botão para abrir a câmera",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: ScannerOverlay(
        height: 650,
        width: 500,
        borderColor: Colors.blueAccent,
        borderRadius: 2,
      ),
    );
  }
}
