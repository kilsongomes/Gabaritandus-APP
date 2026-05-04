// lib/config.dart
import 'package:flutter/foundation.dart';

// ═══════════════════════════════════════════════════════════════════
// 🔥 CONFIGURAÇÃO ÚNICA - MUDE APENAS O IP ABAIXO 🔥
// ═══════════════════════════════════════════════════════════════════

/// IP do computador onde o proxy está rodando
/// Descubra seu IP: ipconfig (Windows) ou ifconfig (Mac/Linux)
const String mobileIp = "192.168.0.103"; // 👈 MUDE AQUI!

/// Porta do proxy (não mexa a menos que tenha mudado no proxy.js)
const int proxyPort = 3000;

// ═══════════════════════════════════════════════════════════════════
// ⚠️ NÃO MEXA DAQUI PARA BAIXO - TUDO É AUTOMÁTICO ⚠️
// ═══════════════════════════════════════════════════════════════════

/// URL base do proxy (funciona para Web e Mobile)
String get proxyUrl {
  if (kIsWeb) {
    final host = Uri.base.host;

    if (host == "localhost" || host == "127.0.0.1") {
      return "http://localhost:$proxyPort";
    }

    return "http://$host:$proxyPort";
  }

  return "http://$mobileIp:$proxyPort";
}

/// URLs específicas (para facilitar)
String get loginApiUrl => "$proxyUrl/login-api";
String get mainApiUrl => "$proxyUrl/api";
String get omrApiUrl => "$proxyUrl/omr";

/// Debug: mostra a configuração atual
void printConfig() {
  debugPrint("\n📱 Configuração atual:");
  debugPrint("   Plataforma: ${kIsWeb ? "Web" : "Mobile"}");
  debugPrint("   Proxy URL: $proxyUrl");
  debugPrint("   Login API: $loginApiUrl");
  debugPrint("   Main API: $mainApiUrl");
  debugPrint("   OMR API: $omrApiUrl\n");
}
