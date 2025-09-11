/*

Login Page
  - This page provides a user interface for users to log in to the application.
  - It includes fields for entering a username and password, as well as buttons for submitting the login form and navigating to the registration page.

  if the user does not have an account, they can navigate to the registration page.

*/

//import 'package:agenda_century/features/auth/presentation/components/my_button.dart';
import 'package:agenda_century/features/auth/presentation/components/my_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Build UI
  @override
  Widget build(BuildContext context) {
    // Scaffold with AppBar
    return Scaffold(
      // Body with padding
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
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
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

              const SizedBox(height: 25),
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 10),
              // password text field
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              // login button

              // oauth login buttons

              // register button
            ],
          ),
        ),
      ),
    );
  }
}
