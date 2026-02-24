import 'dart:io';
import 'package:image/image.dart' as img;

class AnswerSheetProcessor {
  static const int _questionsCount = 10;
  static const int _optionsCount = 4;

  // Ajustado para papel real com caneta
  static const int _blackThreshold = 110;
  static const double _minFillPercentage = 0.28;

  Future<List<String?>> processAnswerSheet(File imageFile) async {
    print("📷 Iniciando processamento da folha...");

    final bytes = await imageFile.readAsBytes();
    final original = img.decodeImage(bytes);

    if (original == null) {
      throw Exception("Erro ao decodificar imagem");
    }

    // Redimensiona para tamanho padrão (mantém proporção)
    final resized = img.copyResize(
      original,
      width: 1000,
    );

    print("🧠 Usando OMR de layout fixo...");
    return _detectFixedLayout(resized);
  }

  /// MÉTODO PRINCIPAL
  /// Ideal para fotos recortadas só do gabarito
  List<String?> _detectFixedLayout(img.Image image) {
    print("📐 Detectando por layout fixo...");

    final grayscale = img.grayscale(image);
    final answers = <String?>[];

    // 🔥 Ajustes baseados no layout da sua folha
    final topMargin = (image.height * 0.05).toInt();
    final bottomMargin = (image.height * 0.05).toInt();
    final leftMargin = (image.width * 0.25).toInt(); // ignora números
    final rightMargin = (image.width * 0.05).toInt();

    final usableHeight = image.height - topMargin - bottomMargin;
    final usableWidth = image.width - leftMargin - rightMargin;

    final questionHeight = usableHeight ~/ _questionsCount;
    final optionWidth = usableWidth ~/ _optionsCount;

    print("   Altura por questão: $questionHeight");
    print("   Largura por opção: $optionWidth");

    for (var q = 0; q < _questionsCount; q++) {
      final yStart = topMargin + (q * questionHeight);

      int bestOption = -1;
      double bestFill = 0.0;

      for (var o = 0; o < _optionsCount; o++) {
        final xStart = leftMargin + (o * optionWidth);

        try {
          // 🔥 Corta apenas o centro da célula (ignora bordas da grade)
          final cell = img.copyCrop(
            grayscale,
            x: xStart + (optionWidth * 0.2).toInt(),
            y: yStart + (questionHeight * 0.2).toInt(),
            width: (optionWidth * 0.6).toInt(),
            height: (questionHeight * 0.6).toInt(),
          );

          final fill = _calculateFillPercentage(cell);

          print(
              "   Q${q + 1} ${String.fromCharCode(65 + o)}: ${fill.toStringAsFixed(3)}");

          if (fill > bestFill) {
            bestFill = fill;
            bestOption = o;
          }
        } catch (e) {
          print("Erro ao processar célula Q${q + 1} Opção $o: $e");
        }
      }

      if (bestOption != -1 && bestFill >= _minFillPercentage) {
        final letter = String.fromCharCode(65 + bestOption);
        answers.add(letter);
        print("✅ Questão ${q + 1}: $letter (fill: ${bestFill.toStringAsFixed(2)})");
      } else {
        answers.add(null);
        print("⚠️ Questão ${q + 1}: não detectada");
      }
    }

    return answers;
  }

  /// 🔥 Calcula porcentagem de pixels escuros
  double _calculateFillPercentage(img.Image cell) {
    int darkPixels = 0;
    int totalPixels = cell.width * cell.height;

    for (int y = 0; y < cell.height; y++) {
      for (int x = 0; x < cell.width; x++) {
        final pixel = cell.getPixel(x, y);
        final luminance = img.getLuminance(pixel);

        if (luminance < _blackThreshold) {
          darkPixels++;
        }
      }
    }

    return darkPixels / totalPixels;
  }
}