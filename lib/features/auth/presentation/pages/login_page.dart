/*

Login Page
  - This page provides a user interface for users to log in to the application.
  - It only provides Google Sign-In option.
  - Includes theme toggle button.

*/

import 'package:agenda_century/features/auth/presentation/components/google_sign_in_button.dart';
import 'package:agenda_century/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:agenda_century/features/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final authCubit = context.read<AuthCubit>();

  // Método para obtener el icono del tema actual
  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  // Método para cambiar el tema
  void _changeThemeMode(ThemeMode newThemeMode) {
    setState(() {
      themeManager.setThemeMode(newThemeMode);
    });
    print('Modo de tema cambiado a: $newThemeMode');
  }

  // Diálogo para seleccionar el modo del tema
  void _showThemeModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar tema'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                ThemeMode.light,
                Icons.light_mode,
                'Modo claro',
                'Usar tema claro',
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                ThemeMode.dark,
                Icons.dark_mode,
                'Modo oscuro',
                'Usar tema oscuro',
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                ThemeMode.system,
                Icons.brightness_auto,
                'Sistema',
                'Usar configuración del sistema',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cerrar',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode themeMode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final bool isSelected = themeManager.currentThemeMode == themeMode;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        _changeThemeMode(themeMode);
        Navigator.of(context).pop();
      },
      tileColor: isSelected
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Botón para cambiar tema en la esquina superior derecha
          IconButton(
            icon: Icon(_getThemeIcon(themeManager.currentThemeMode)),
            onPressed: () => _showThemeModeDialog(context),
            tooltip: 'Cambiar tema',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              Icon(
                Icons.lock_open,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 25),

              // name of app
              Text(
                'Agenda de Salas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),

              const SizedBox(height: 8),

              // subtitle
              Text(
                'Inicia sesión para continuar',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 50),

              // google button
              MyGoogleSignInButton(
                onTap: () async {
                  await authCubit.signInGoogle();
                },
              ),

              const SizedBox(height: 30),

              // Información sobre el tema
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.palette,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tema actual: ${_getThemeName(themeManager.currentThemeMode)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Puedes cambiar el tema en cualquier momento',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
