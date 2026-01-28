import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/controller/auth_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showNotifications;
  final bool showMenu;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.title = "Gabaritandus",
    this.showBackButton = false,
    this.showNotifications = true,
    this.showMenu = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF00B4D8),
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: actions ?? _buildDefaultActions(context),
    );
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    final List<Widget> defaultActions = [];

    // Ícone de notificações
    if (showNotifications) {
      defaultActions.add(
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black87),
          onPressed: () {
            // Futuramente: abrir notificações
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Notificações em desenvolvimento")),
            );
          },
        ),
      );
    }

    // Menu de opções (logout)
    if (showMenu) {
      defaultActions.add(
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          onSelected: (value) {
            if (value == 'logout') {
              final authController = Provider.of<AuthController>(context, listen: false);
              authController.showLogoutDialog(context);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sair', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return defaultActions;
  }
}