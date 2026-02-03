// auth_controller.dart - ADICIONAR LOGS DETALHADOS
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'dart:convert';

enum LoginResult { success, blockedRole, invalid }

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _user;
  bool _saveInfo = false;
  bool _passwordVisible = false;
  String? _userName;
  String? _userRole;
  String? _userPhoto;
  int? _groupId;

  // Getters públicos
  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  bool get saveInfo => _saveInfo;
  bool get passwordVisible => _passwordVisible;
  String? get userName => _userName;
  String? get userRole => _userRole;
  String? get userPhoto => _userPhoto;
  int? get groupId => _groupId;

  // Método para alternar visibilidade da senha
  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  // Método para definir se deve salvar informações
  void setSaveInfo(bool value) {
    print("📝 [AuthController] setSaveInfo($value) chamado");
    _saveInfo = value;
    notifyListeners();
    
    // Se desmarcar o checkbox, limpar credenciais imediatamente
    if (!value) {
      print("🗑️ [AuthController] Checkbox desmarcado, limpando credenciais...");
      _clearSavedLoginInfo();
    }
  }

  // Carregar informações salvas
  Future<void> loadSavedLoginInfo() async {
    print("🔍 [AuthController] loadSavedLoginInfo() chamado");
    final prefs = await SharedPreferences.getInstance();
    _saveInfo = prefs.getBool('save_info') ?? false;
    print("   save_info carregado: $_saveInfo");
    notifyListeners();
  }

  // Carregar credenciais salvas
  Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('saved_username');
    final password = prefs.getString('saved_password');
    
    print("🔑 [AuthController] getSavedCredentials()");
    print("   username salvo: $username");
    print("   password salvo: ${password != null ? "***${password.length} chars***" : "null"}");
    
    return {
      'username': username,
      'password': password,
    };
  }

  Future<LoginResult> login(String username, String password) async {
    print("🚀 [AuthController] login() iniciado");
    print("   username: $username");
    print("   saveInfo: $_saveInfo");
    
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

    final userId = await _authService.login(username, password);
    _loading = false;

    if (userId != null) {
      print("✅ [AuthController] Login API bem-sucedido");
      
      // Carregar dados do usuário
      await _loadUserData();
      
      // SALVAR OU LIMPAR CREDENCIAIS CONFORME CHECKBOX
      if (_saveInfo) {
        print("💾 [AuthController] Salvando credenciais (saveInfo=true)");
        await _saveLoginInfo(username, password);
      } else {
        print("🗑️ [AuthController] Não salvando credenciais (saveInfo=false)");
        await _clearSavedLoginInfo();
      }
      
      // Verificar role bloqueada
      final blockedRoles = ["Estudante", "Aluno"];
      
      if (blockedRoles.contains(_userRole)) {
        _error = "Seu perfil não tem acesso permitido";
        notifyListeners();
        return LoginResult.blockedRole;
      }
      
      print("✅ [AuthController] login() concluído com sucesso");
      notifyListeners();
      return LoginResult.success;
    } else {
      _error = "Credenciais inválidas";
      notifyListeners();
      return LoginResult.invalid;
    }
  }

  Future<void> _loadUserData() async {
    print("📂 [AuthController] _loadUserData() chamado");
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // Carregar dados completos do usuário
      final userJson = prefs.getString("user");
      if (userJson != null) {
        _user = jsonDecode(userJson);
        print("✅ [AuthController] Dados do usuário carregados do JSON");
      }
      
      // Carregar campos individuais
      _userName = prefs.getString("user_name");
      _userRole = prefs.getString("user_role");
      _userPhoto = prefs.getString("user_photo");
      _groupId = prefs.getInt("group_id");
      
      print("📊 [AuthController] Dados carregados do SharedPreferences:");
      print("   👤 user_name: $_userName");
      print("   🎭 user_role: $_userRole");
      print("   🏢 group_id: $_groupId");
      print("   📸 user_photo: $_userPhoto");
      
    } catch (e) {
      print("❌ [AuthController] Erro ao carregar dados: $e");
    }
  }

  // Salvar informações de login
  Future<void> _saveLoginInfo(String username, String password) async {
    try {
      print("💾 [AuthController] _saveLoginInfo() chamado");
      print("   Salvando username: $username");
      print("   Salvando password: ***${password.length} chars***");
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_username', username);
      await prefs.setString('saved_password', password);
      await prefs.setBool('save_info', true);
      
      // Verificar se salvou
      final savedUsername = prefs.getString('saved_username');
      final savedPassword = prefs.getString('saved_password');
      final savedInfo = prefs.getBool('save_info');
      
      print("✅ [AuthController] Credenciais salvas:");
      print("   saved_username: $savedUsername");
      print("   saved_password: ${savedPassword != null ? "SALVO" : "NÃO SALVO"}");
      print("   save_info: $savedInfo");
      
    } catch (e) {
      print("❌ [AuthController] Erro ao salvar credenciais: $e");
    }
  }

  // Limpar informações salvas (APENAS credenciais)
  Future<void> _clearSavedLoginInfo() async {
    try {
      print("🗑️ [AuthController] _clearSavedLoginInfo() chamado");
      
      final prefs = await SharedPreferences.getInstance();
      
      // Verificar antes de limpar
      final usernameBefore = prefs.getString('saved_username');
      final passwordBefore = prefs.getString('saved_password');
      
      print("   Antes de limpar:");
      print("     saved_username: $usernameBefore");
      print("     saved_password: ${passwordBefore != null ? "EXISTE" : "NÃO EXISTE"}");
      
      // Limpar
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
      await prefs.setBool('save_info', false);
      
      // Verificar depois de limpar
      final usernameAfter = prefs.getString('saved_username');
      final passwordAfter = prefs.getString('saved_password');
      final saveInfoAfter = prefs.getBool('save_info');
      
      print("   Depois de limpar:");
      print("     saved_username: $usernameAfter");
      print("     saved_password: ${passwordAfter != null ? "EXISTE" : "NÃO EXISTE"}");
      print("     save_info: $saveInfoAfter");
      
      print("✅ [AuthController] Credenciais removidas com sucesso");
      
    } catch (e) {
      print("❌ [AuthController] Erro ao limpar credenciais: $e");
    }
  }

  // Método para carregar dados do usuário
  Future<void> loadUserData() async {
    await _loadUserData();
    notifyListeners();
  }

  // Logout - APENAS limpa sessão, mantém credenciais se salvas
  Future<void> logout() async {
    print("🚪 [AuthController] logout() iniciado");
    
    // Verificar estado antes do logout
    print("   Estado antes do logout:");
    print("     saveInfo: $_saveInfo");
    print("     userName: $_userName");
    
    // Limpar apenas dados da sessão
    print("   Chamando _authService.logout()...");
    await _authService.logout();
    
    // Limpar apenas dados da sessão local
    _user = null;
    _userName = null;
    _userRole = null;
    _userPhoto = null;
    _groupId = null;
    
    // NÃO limpar credenciais salvas aqui!
    
    // Verificar estado depois do logout
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username');
    final savedPassword = prefs.getString('saved_password');
    final saveInfo = prefs.getBool('save_info');
    
    print("   Estado depois do logout:");
    print("     saved_username (SharedPreferences): $savedUsername");
    print("     saved_password (SharedPreferences): ${savedPassword != null ? "SALVO" : "NÃO SALVO"}");
    print("     save_info (SharedPreferences): $saveInfo");
    print("     _saveInfo (variável local): $_saveInfo");
    
    print("✅ [AuthController] logout() concluído");
    notifyListeners();
  }

  // Função para mostrar diálogo de logout
  Future<void> showLogoutDialog(BuildContext context) async {
    print("💬 [AuthController] showLogoutDialog() chamado");
    
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sair do App"),
          content: const Text("Tem certeza que deseja sair?"),
          actions: [
            TextButton(
              onPressed: () {
                print("   Usuário cancelou logout");
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                print("   Usuário confirmou logout");
                Navigator.of(context).pop(true);
              },
              child: const Text("Sair", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      print("✅ Usuário confirmou, executando logout...");
      await performLogout(context);
    } else {
      print("❌ Usuário cancelou logout");
    }
  }

  // Função para executar o logout
  Future<void> performLogout(BuildContext context) async {
    print("🔧 [AuthController] performLogout() iniciado");
    
    try {
      // Mostrar loading
      print("   Mostrando diálogo de loading...");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Executar logout (mantém credenciais)
      print("   Executando logout...");
      await logout();

      // Fechar loading e navegar para login
      if (context.mounted) {
        print("   Fechando diálogo de loading...");
        Navigator.of(context).pop(); // Fecha o loading
        
        print("   Navegando para /login...");
        Navigator.of(context).pushReplacementNamed('/login');
      }
      
      print("✅ [AuthController] performLogout() concluído");
    } catch (e) {
      print("❌ [AuthController] Erro em performLogout: $e");
      
      // Em caso de erro, ainda redireciona para login
      if (context.mounted) {
        Navigator.of(context).pop(); // Fecha o loading
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}