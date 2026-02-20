// lib/features/exams/answer_sheet/services/answer_sheet_reader.dart

import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class _GridBounds {
  final int left;
  final int top;
  final int width;
  final int height;

  _GridBounds(this.left, this.top, this.width, this.height);

  int get right => left + width;
  int get bottom => top + height;
}

class AnswerSheetReader {
  // Constantes para configuração da grade
  static const int _questionsCount = 10; // Quantidade de questões
  static const int _optionsCount = 5; // A, B, C, D, E
  
  // Limiar para considerar uma bolha como preenchida (0-255, quanto menor, mais escuro)
  static const int _bubbleThreshold = 128;
  
  // Tamanho mínimo de uma bolha (em pixels) - ajustar conforme necessidade

  /// Processa a imagem e extrai as respostas
  Future<List<String?>> processAnswerSheet(ui.Image image) async {
    print("📸 [AnswerSheetReader] Iniciando processamento da folha de respostas");
    print("   Dimensões da imagem: ${image.width} x ${image.height}");
    
    // Converter ui.Image para img.Image
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    
    // 🔥 CORREÇÃO: byteData pode ser null
    if (byteData == null) {
      print("❌ [AnswerSheetReader] Erro ao obter bytes da imagem");
      return List.filled(_questionsCount, null);
    }
    
    // 🔥 CORREÇÃO: Obter o buffer corretamente
    final buffer = byteData.buffer; // Isso já é um ByteBuffer
    final bytes = buffer.asUint8List(); // Converter para Uint8List se necessário
    
    print("   Bytes da imagem: ${bytes.length} bytes");
    
    // 🔥 CORREÇÃO: Usar o buffer diretamente, não os bytes
    final imgImage = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: buffer, // Aqui espera ByteBuffer, não Uint8List
      order: img.ChannelOrder.rgba,
    );
    
    // 1. Pré-processamento
    final processed = _preprocessImage(imgImage);
    
    // 2. Detectar a grade de alternativas
    final gridBounds = _detectAnswerGrid(processed);
    if (gridBounds == null) {
      print("❌ [AnswerSheetReader] Não foi possível detectar a grade de respostas");
      return List.filled(_questionsCount, null);
    }
    
    // 3. Extrair células da grade
    final cells = _extractGridCells(processed, gridBounds);
    
    // 4. Analisar cada célula para detectar marcação
    final answers = <String?>[];
    for (var i = 0; i < cells.length; i++) {
      final answer = _analyzeCell(cells[i]);
      answers.add(answer);
      print("   Questão ${i + 1}: ${answer ?? 'não detectado'}");
    }
    
    print("✅ [AnswerSheetReader] Processamento concluído");
    return answers;
  }

  /// Pré-processamento da imagem (escala de cinza, binarização, etc)
  img.Image _preprocessImage(img.Image image) {
    print("🔄 [AnswerSheetReader] Pré-processando imagem...");
    
    // Converter para escala de cinza
    final grayscale = img.grayscale(image);
    
    // Criar nova imagem para binarização
    final binary = img.Image(width: grayscale.width, height: grayscale.height, numChannels: 1);
    
    for (var y = 0; y < grayscale.height; y++) {
      for (var x = 0; x < grayscale.width; x++) {
        // getPixel retorna Pixel, pegamos o red channel como luminance
        final pixel = grayscale.getPixel(x, y);
        final luminance = pixel.r.toInt(); // Pega o valor do canal R
        
        // Se for mais escuro que o limiar, considera preto, senão branco
        if (luminance < _bubbleThreshold) {
          binary.setPixelRgb(x, y, 0, 0, 0); // Preto
        } else {
          binary.setPixelRgb(x, y, 255, 255, 255); // Branco
        }
      }
    }
    
    return binary;
  }

  /// Detectar a região da grade de respostas
  _GridBounds? _detectAnswerGrid(img.Image image) {
    print("🔍 [AnswerSheetReader] Detectando grade de respostas...");
    
    // 1. Detectar linhas horizontais
    final horizontalLines = <int>[];
    
    for (var y = 0; y < image.height; y++) {
      var blackPixels = 0;
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = pixel.r.toInt();
        if (luminance < _bubbleThreshold) {
          blackPixels++;
        }
      }
      
      // Se tiver muitos pixels pretos, é provavelmente uma linha horizontal
      if (blackPixels > image.width * 0.7) {
        horizontalLines.add(y);
      }
    }
    
    // 2. Detectar linhas verticais
    final verticalLines = <int>[];
    for (var x = 0; x < image.width; x++) {
      var blackPixels = 0;
      for (var y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        final luminance = pixel.r.toInt();
        if (luminance < _bubbleThreshold) {
          blackPixels++;
        }
      }
      
      // Se tiver muitos pixels pretos, é provavelmente uma linha vertical
      if (blackPixels > image.height * 0.7) {
        verticalLines.add(x);
      }
    }
    
    // Agrupar linhas próximas (remover duplicatas)
    final uniqueHorizontal = _mergeCloseLines(horizontalLines, 10);
    final uniqueVertical = _mergeCloseLines(verticalLines, 10);
    
    print("   Linhas horizontais detectadas: ${uniqueHorizontal.length}");
    print("   Linhas verticais detectadas: ${uniqueVertical.length}");
    
    // Precisamos de pelo menos 11 linhas horizontais (10 questões + bordas)
    // e 6 linhas verticais (5 alternativas + bordas)
    if (uniqueHorizontal.length < 11 || uniqueVertical.length < 6) {
      print("⚠️ [AnswerSheetReader] Grade incompleta detectada");
      return null;
    }
    
    // Pegar a maior região que contém a grade
    final top = uniqueHorizontal.first;
    final bottom = uniqueHorizontal.last;
    final left = uniqueVertical.first;
    final right = uniqueVertical.last;
    
    print("   Grade detectada: top=$top, bottom=$bottom, left=$left, right=$right");
    
    return _GridBounds(left, top, right - left, bottom - top);
  }

  /// Mescla linhas que estão muito próximas
  List<int> _mergeCloseLines(List<int> lines, int distance) {
    if (lines.isEmpty) return [];
    
    lines.sort();
    final merged = <int>[lines.first];
    
    for (var i = 1; i < lines.length; i++) {
      if (lines[i] - merged.last > distance) {
        merged.add(lines[i]);
      }
    }
    
    return merged;
  }

  /// Extrai cada célula da grade
  List<img.Image> _extractGridCells(img.Image image, _GridBounds gridBounds) {
    print("🔲 [AnswerSheetReader] Extraindo células da grade...");
    
    final cells = <img.Image>[];
    
    // Dividir a grade em questões (linhas) e alternativas (colunas)
    final questionHeight = gridBounds.height ~/ _questionsCount;
    final optionWidth = gridBounds.width ~/ _optionsCount;
    
    for (var q = 0; q < _questionsCount; q++) {
      for (var o = 0; o < _optionsCount; o++) {
        final x = gridBounds.left + (o * optionWidth) + (optionWidth ~/ 4);
        final y = gridBounds.top + (q * questionHeight) + (questionHeight ~/ 4);
        final width = optionWidth ~/ 2;
        final height = questionHeight ~/ 2;
        
        // Verificar se as coordenadas estão dentro dos limites da imagem
        if (x + width <= image.width && y + height <= image.height) {
          // copyCrop retorna Image
          final cell = img.copyCrop(image, x: x, y: y, width: width, height: height);
          cells.add(cell);
        }
      }
    }
    
    print("   Extraídas ${cells.length} células");
    return cells;
  }

  /// Analisa uma célula para determinar qual alternativa foi marcada
  String? _analyzeCell(img.Image cell) {
    // Contar pixels pretos na célula
    var blackPixels = 0;
    var totalPixels = cell.width * cell.height;
    
    for (var y = 0; y < cell.height; y++) {
      for (var x = 0; x < cell.width; x++) {
        final pixel = cell.getPixel(x, y);
        final luminance = pixel.r.toInt();
        if (luminance < _bubbleThreshold) {
          blackPixels++;
        }
      }
    }
    
    final blackPercentage = blackPixels / totalPixels;
    
    // Se mais de 15% da área está preenchida, considera como marcada
    if (blackPercentage > 0.15) {
      return "X";
    }
    
    return null;
  }
}