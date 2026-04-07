import 'dart:convert';
import 'dart:io';
import '../controller/api_config.dart';

class AnswerSheetApiService {
  static const String baseUrl = ApiConfig.baseUrl;
  
  Future<List<String?>> processAnswerSheet(File imageFile, int numberOfQuestions) async {
    HttpClient? httpClient;
    
    try {
      print("📤 [AnswerSheetApiService] Enviando imagem para API...");
      print("   Número de questões: $numberOfQuestions");
      print("   Caminho da imagem: ${imageFile.path}");
      
      // Check if file exists and get its size
      if (!await imageFile.exists()) {
        throw Exception("Arquivo de imagem não encontrado");
      }
      
      final fileSize = await imageFile.length();
      print("   Tamanho do arquivo: $fileSize bytes");
      
      // Escolher a rota baseada no número de questões
      final endpoint = numberOfQuestions == 20 
          ? "/processar_20_questoes" 
          : "/processar_10_questoes";
          
      print("   📍 Usando endpoint: $endpoint (baseado em $numberOfQuestions questões)");
      final uri = Uri.parse("$baseUrl$endpoint");
      print("   URL: $uri");
      
      // Criar HttpClient com timeout
      httpClient = HttpClient()
        ..badCertificateCallback = 
            ((X509Certificate cert, String host, int port) => true)
        ..connectionTimeout = const Duration(seconds: 30);
      
      final request = await httpClient.postUrl(uri);
      
      // Criar boundary para multipart
      final boundary = '----FlutterBoundary${DateTime.now().millisecondsSinceEpoch}';
      final contentType = 'multipart/form-data; boundary=$boundary';
      request.headers.set('Content-Type', contentType);
      request.headers.set('Accept', 'application/json');
      
      // Ler a imagem
      final bytes = await imageFile.readAsBytes();
      print("   Imagem carregada: ${bytes.length} bytes");
      
      // Criar o corpo multipart manualmente
      // ignore: deprecated_export_use
      final buffer = BytesBuilder();
      
      // Adicionar o arquivo
      buffer.add(utf8.encode('--$boundary\r\n'));
      buffer.add(utf8.encode('Content-Disposition: form-data; name="file"; filename="answer_sheet.jpg"\r\n'));
      buffer.add(utf8.encode('Content-Type: image/jpeg\r\n\r\n'));
      buffer.add(bytes);
      buffer.add(utf8.encode('\r\n'));
      
      // Finalizar boundary
      buffer.add(utf8.encode('--$boundary--\r\n'));
      
      // Enviar os dados
      request.add(buffer.toBytes());
      
      // Enviar e receber resposta
      print("   Enviando requisição...");
      final response = await request.close();
      
      print("   Status Code: ${response.statusCode}");
      
      // Ler resposta com timeout
      final responseBody = await response.transform(utf8.decoder).join();
      
      print("⬅️ [AnswerSheetApiService] Response Body: $responseBody");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        
        if (data["success"] == true) {
          // Processar as respostas no formato da sua API
          final respostasRaw = data["respostas"] as List;
          final totalQuestoes = data["questoes"] as int;
          
          print("   Total de questões esperadas: $totalQuestoes");
          print("   Respostas recebidas: ${respostasRaw.length}");
          
          // Criar lista de respostas no formato esperado pelo app
          List<String?> extractedAnswers = List<String?>.filled(totalQuestoes, null);
          
          // Preencher as respostas
          for (var item in respostasRaw) {
            final numero = item["numero"] as int;
            final resposta = item["resposta"] as String?;
            final respondida = item["respondida"] as bool;
            
            print("   Questão $numero: respondida=$respondida, resposta=$resposta");
            
            if (respondida && resposta != null && resposta.isNotEmpty) {
              final index = numero - 1;
              if (index < extractedAnswers.length) {
                extractedAnswers[index] = resposta;
              }
            }
          }
          
          final totalRespondidas = extractedAnswers.where((a) => a != null).length;
          print("✅ [AnswerSheetApiService] Processamento concluído");
          print("   Total de respostas detectadas: $totalRespondidas de $totalQuestoes");
          
          httpClient.close();
          return extractedAnswers;
        } else {
          throw Exception(data["message"] ?? "Erro ao processar imagem");
        }
      } else {
        throw Exception("Erro HTTP ${response.statusCode}: $responseBody");
      }
      
    } catch (e) {
      print("❌ [AnswerSheetApiService] Erro: $e");
      print("   Stack trace: ${StackTrace.current}");
      rethrow;
    } finally {
      httpClient?.close();
    }
  }
  
  // Método para testar a conexão com a API
  Future<bool> testConnection() async {
    HttpClient? httpClient;
    
    try {
      print("🔌 [AnswerSheetApiService] Testando conexão com a API...");
      final uri = Uri.parse("$baseUrl/");
      
      httpClient = HttpClient()
        ..badCertificateCallback = 
            ((X509Certificate cert, String host, int port) => true)
        ..connectionTimeout = const Duration(seconds: 10);
      
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);
        print("✅ [AnswerSheetApiService] Conexão OK!");
        print("   Resposta: ${data['message']}");
        httpClient.close();
        return true;
      } else {
        print("❌ [AnswerSheetApiService] Erro na conexão: ${response.statusCode}");
        httpClient.close();
        return false;
      }
    } catch (e) {
      print("❌ [AnswerSheetApiService] Erro de conexão: $e");
      print("   Verifique se:");
      print("   1. O servidor está rodando: $baseUrl");
      print("   2. O celular tem acesso à internet");
      print("   3. O servidor Render está online");
      return false;
    } finally {
      httpClient?.close();
    }
  }
}