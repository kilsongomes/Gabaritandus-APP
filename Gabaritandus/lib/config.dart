import 'package:flutter/foundation.dart';

/// Proxy online (Render)
const String productionProxy =
    "https://proxy-login.onrender.com";

/// Proxy local para celular
const String mobileIp = "192.168.0.28";
const int proxyPort = 3000;

/// Detecta ambiente automaticamente
String get proxyUrl {
  if (kIsWeb) {
    final host = Uri.base.host;

    // Desenvolvimento local no navegador
    if (host == "localhost" || host == "127.0.0.1") {
      return "http://localhost:$proxyPort";
    }

    // Produção (Netlify)
    return productionProxy;
  }

  // Android / iPhone local
  return "http://$mobileIp:$proxyPort";
}

/// Endpoints
String get loginApiUrl => "$proxyUrl/login-api";
String get mainApiUrl => "$proxyUrl/api";
String get omrApiUrl => "$proxyUrl/omr";

/// Debug
void printConfig() {
  debugPrint("📱 Ambiente:");
  debugPrint("Plataforma: ${kIsWeb ? "Web" : "Mobile"}");
  debugPrint("Proxy URL: $proxyUrl");
  debugPrint("Login: $loginApiUrl");
  debugPrint("API: $mainApiUrl");
  debugPrint("OMR: $omrApiUrl");
}