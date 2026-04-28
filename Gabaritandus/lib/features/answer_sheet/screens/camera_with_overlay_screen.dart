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
  String? _cameraError;
  final ImagePicker _picker = ImagePicker();

  bool get _useWebCamera =>
      kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();

    if (!kIsWeb || _useWebCamera) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _cameraError =
              'Nenhuma câmera foi encontrada. No navegador, verifique se a página está em HTTPS ou localhost.';
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _cameraError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraError =
              'Não foi possível iniciar a câmera. No navegador, use HTTPS ou localhost. Detalhe: $e';
        });
      }
      print("❌ Erro ao inicializar câmera: $e");
    }
  }

  Future<void> _takePicture() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final XFile picture = await controller.takePicture();

      if (!mounted) return;

      Navigator.pop(context, picture);
    } catch (e) {
      print("❌ Erro ao tirar foto: $e");
    }
  }

  Future<void> _pickImageWeb() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      Navigator.pop(context, image);
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraError = 'Não foi possível selecionar a imagem. Detalhe: $e';
        });
      }
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
          ? (_useWebCamera ? _buildWebCameraView() : _buildWebFileView())
          : _buildMobileView(),

      floatingActionButton: FloatingActionButton(
        onPressed: kIsWeb
            ? (_useWebCamera ? _takePicture : _pickImageWeb)
            : _takePicture,
        backgroundColor: const Color(0xff004aad),
        child: Icon(
          kIsWeb ? (_useWebCamera ? Icons.camera : Icons.upload_file) : Icons.camera,
        ),
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

  Widget _buildMobileView() {
    if (_cameraError != null) {
      return _buildCameraError();
    }

    return _isCameraInitialized
        ? _buildCameraView()
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildWebCameraView() {
    if (_cameraError != null) {
      return _buildCameraError();
    }

    return _isCameraInitialized
        ? _buildCameraView()
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildWebFileView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload_file, size: 64, color: Color(0xff004aad)),
            const SizedBox(height: 12),
            const Text(
              'Selecione a imagem do gabarito',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'No computador, use um arquivo de imagem em vez da câmera.',
              textAlign: TextAlign.center,
            ),
            if (_cameraError != null) ...[
              const SizedBox(height: 12),
              Text(
                _cameraError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCameraError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              _cameraError ?? 'Erro ao iniciar a câmera.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
