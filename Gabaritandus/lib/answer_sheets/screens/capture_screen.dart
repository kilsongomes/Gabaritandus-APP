// lib/answer_sheets/screens/capture_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/widgets/custom_app_bar.dart';

class CaptureScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String classroomId;
  final String classroomName;
  final String discipline;

  const CaptureScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
    required this.classroomId,
    required this.classroomName,
    required this.discipline,
  }) : super(key: key);

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  File? _capturedImage;
  bool _isProcessing = false;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.studentName,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do aluno
            _buildStudentInfo(),
            const SizedBox(height: 20),

            // Status atual
            _buildStatusCard(),
            const SizedBox(height: 20),

            // Preview da imagem (se já capturada)
            if (_capturedImage != null) ...[
              _buildImagePreview(),
              const SizedBox(height: 20),
            ],

            // Botões de ação
            if (_capturedImage == null) ...[
              _buildCaptureButtons(),
            ] else ...[
              _buildActionButtons(),
            ],

            // Loading/erro
            if (_isProcessing) _buildProcessingIndicator(),
            if (_errorMessage != null) _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  widget.studentName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.school, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  "Disciplina: ${widget.discipline}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (_capturedImage != null) {
      statusText = "Gabarito Capturado";
      statusColor = Colors.blue;
      statusIcon = Icons.check_circle;
    } else if (_errorMessage != null) {
      statusText = "Erro na Captura";
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else {
      statusText = "Aguardando Captura";
      statusColor = Colors.grey;
      statusIcon = Icons.pending;
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.photo_camera),
                SizedBox(width: 8),
                Text(
                  "Prévia do Gabarito",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              image: DecorationImage(
                image: FileImage(_capturedImage!),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButtons() {
    return Column(
      children: [
        const Text(
          "Capture o gabarito do aluno",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          "Dicas para uma boa foto:",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "• Iluminação uniforme\n"
            "• Gabarito totalmente visível\n"
            "• Evite sombras\n"
            "• Foto na horizontal",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 30),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Tirar foto
            ElevatedButton.icon(
              onPressed: () => _captureImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Tirar Foto"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4D8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),

            // Escolher da galeria
            ElevatedButton.icon(
              onPressed: () => _captureImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Da Galeria"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Refazer foto
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _capturedImage = null;
              _errorMessage = null;
            });
          },
          icon: const Icon(Icons.refresh),
          label: const Text("Refazer"),
        ),

        // Processar gabarito
        ElevatedButton.icon(
          onPressed: _processAnswerSheet,
          icon: const Icon(Icons.check),
          label: const Text("Processar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),

        // Salvar e voltar
        ElevatedButton.icon(
          onPressed: _saveAndReturn,
          icon: const Icon(Icons.save),
          label: const Text("Salvar"),
        ),
      ],
    );
  }

  Widget _buildProcessingIndicator() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 10),
          Text(
            _capturedImage != null 
              ? "Processando gabarito..." 
              : "Validando imagem...",
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      setState(() {
        _isProcessing = true;
        _errorMessage = null;
      });

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (image != null) {
        // TODO: Validar qualidade da imagem
        final bool isValid = await _validateImageQuality(File(image.path));
        
        if (isValid) {
          setState(() {
            _capturedImage = File(image.path);
            _isProcessing = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gabarito capturado com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _errorMessage = "Qualidade da imagem insuficiente. Por favor, refaça a foto.";
            _isProcessing = false;
          });
        }
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao capturar imagem: $e";
        _isProcessing = false;
      });
    }
  }

  Future<bool> _validateImageQuality(File image) async {
    // TODO: Implementar validação real da qualidade
    // Verificar: brilho, contraste, foco, se o gabarito está inteiro, etc.
    
    // Por enquanto, validação básica
    final size = await image.length();
    if (size < 10000) { // Muito pequena
      return false;
    }
    
    // Simulação de processamento
    await Future.delayed(const Duration(seconds: 1));
    
    return true; // Temporário - sempre aceita
  }

  void _processAnswerSheet() {
    // TODO: Implementar processamento do gabarito
    // Extrair respostas, validar, enviar para API
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Processar Gabarito"),
        content: const Text(
          "Deseja processar este gabarito agora?\n"
          "O sistema irá extrair as respostas do aluno.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startProcessing();
            },
            child: const Text("Processar"),
          ),
        ],
      ),
    );
  }

  void _startProcessing() {
    // TODO: Iniciar processamento real
    print("Processando gabarito de ${widget.studentName}");
  }

  void _saveAndReturn() {
    // TODO: Salvar localmente e voltar
    if (_capturedImage != null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Capture uma foto primeiro!"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}