/*

Auth Page - Decides whether to show Login or Register Page
  - This page serves as a container that decides whether to display the login page or the registration page based on user interaction.
  - It uses a boolean state variable to toggle between the two pages when the user opts to switch.

*/

import 'package:agenda_century/features/auth/presentation/pages/login_page.dart';
import 'package:agenda_century/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(togglePages: togglePages);
    } else {
      return RegisterPage(togglePages: togglePages);
    }
  }
}
