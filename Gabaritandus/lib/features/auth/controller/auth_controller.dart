import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoginResult { success, blockedRole, invalid }

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _user;
  bool _saveInfo = false; // Controlar checkbox
  bool _passwordVisible = false; // Controlar visibilidade da senha
  String? _userName;
  String? _userRole;
  String? _userPhoto;

  // Getters públicos
  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  bool get saveInfo => _saveInfo; // Getter para checkbox
  bool get passwordVisible => _passwordVisible; // Getter para visibilidade da senha
  String? get userName => _userName;
  String? get userRole => _userRole; 
  String? get userPhoto => _userPhoto; 

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString("user_name");
    _userRole = prefs.getString("user_role") ?? "Professor"; 
    _userPhoto = prefs.getString("user_photo"); 
    notifyListeners();
  }

  // Método para alternar visibilidade da senha
  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  // Método para definir se deve salvar informações
  void setSaveInfo(bool value) {
    _saveInfo = value;
    notifyListeners();
  }

  // Carregar informações salvas ao inicializar
  Future<void> loadSavedLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _saveInfo = prefs.getBool('save_info') ?? false;
    notifyListeners();
  }

  // Salvar informações de login
  Future<void> _saveLoginInfo(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_username', username);
    await prefs.setString('saved_password', password);
    await prefs.setBool('save_info', true);
  }

  // Limpar informações salvas
  Future<void> _clearSavedLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_username');
    await prefs.remove('saved_password');
    await prefs.setBool('save_info', false);
  }

  // Carregar credenciais salvas
  Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('saved_username'),
      'password': prefs.getString('saved_password'),
    };
  }

  Future<LoginResult> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _loading = false;
      _error = username.isEmpty && password.isEmpty
          ? "Usuário e senha são obrigatórios"
          : username.isEmpty
          ? "Usuário é obrigatório"
          : "Senha é obrigatória";
      notifyListeners();
      return LoginResult.invalid;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    final response = await _authService.login(username, password);
    _loading = false;

    if (response != null) {
      //Busca os dados salvos no SharedPreferences após login bem-sucedido
      await loadUserData();
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString("user");
      final rolesJson = prefs.getString("roles");

      if (userJson != null) {
        _user = jsonDecode(userJson);
      }

      //Verificar roles bloqueadas
      final blockedRoles = [7, 8, 9];
      bool hasBlockedRole = false;

      if (rolesJson != null && rolesJson.isNotEmpty) {
        final roles = jsonDecode(rolesJson) as List<dynamic>;

        for (final role in roles) {
          final roleMap = Map<String, dynamic>.from(role);
          final roleId = roleMap["role_id"];

          if (blockedRoles.contains(roleId)) {
            hasBlockedRole = true;
            break;
          }
        }
      }

      // SALVAR INFORMAÇÕES SE SOLICITADO
      if (_saveInfo) {
        await _saveLoginInfo(username, password);
      } else {
        await _clearSavedLoginInfo();
      }

      // Se tem role bloqueada, vai para info screen
      if (hasBlockedRole) {
        _error = "Seu perfil não tem acesso permitido";
        notifyListeners();
        return LoginResult.blockedRole;
      }

      notifyListeners();
      return LoginResult.success;
    } else {
      _error = "Credenciais inválidas";
      notifyListeners();
      return LoginResult.invalid;
    }
  }

  // Função para mostrar diálogo de logout
  Future<void> showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sair do App"),
          content: const Text("Tem certeza que deseja sair?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Sair", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await performLogout(context);
    }
  }

  //Função para executar o logout
  Future<void> performLogout(BuildContext context) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Executar logout
      await logout();

      // Fechar loading e navegar para login
      if (context.mounted) {
        Navigator.of(context).pop(); // Fecha o loading
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Em caso de erro, ainda redireciona para login
      if (context.mounted) {
        Navigator.of(context).pop(); // Fecha o loading
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _userName = null;
    _userRole = null; // 🆕 LIMPAR ROLE
    _userPhoto = null; 
    notifyListeners();
  }
}
