import 'package:flutter/foundation.dart';

String get baseUrl {
  if (kIsWeb) return "";
  return "http://SEU_IP:3000";
}

String get loginApiUrl => "$baseUrl/login-api";
String get mainApiUrl => "$baseUrl/api";
String get omrApiUrl => "$baseUrl/omr";