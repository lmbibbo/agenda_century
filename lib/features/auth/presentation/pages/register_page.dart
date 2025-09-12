import 'package:agenda_century/features/auth/presentation/components/my_button.dart';
import 'package:agenda_century/features/auth/presentation/components/my_textfield.dart';
import 'package:agenda_century/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void register() {
    // prepare info
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty &&
        name.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      // ensure password match
      if (password == confirmPassword) {
        authCubit.register(email, password, name);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields!")));
    }
  }

  @override
  void dispose(){
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

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
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

              const SizedBox(height: 25),
              MyTextField(
                controller: nameController,
                hintText: 'Name',
                obscureText: false,
              ),

              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              // Confirm password text field
              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),

              // register button
              const SizedBox(height: 25),
              MyButton(onTap: register, text: 'Register'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already a member?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: Text(
                      "Login now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
