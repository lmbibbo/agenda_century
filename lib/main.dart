import 'package:agenda_century/features/auth/data/firebase_auth_repo.dart';
import 'package:agenda_century/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:agenda_century/features/auth/presentation/cubits/auth_states.dart';
import 'package:agenda_century/features/auth/presentation/pages/auth_page.dart';
import 'package:agenda_century/features/home/presentation/pages/home_page.dart';
import 'package:agenda_century/features/themes/dark_mode.dart';
import 'package:agenda_century/features/themes/light_mode.dart';
import 'package:agenda_century/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  // firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // run app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _firebaseAuthRepo = FirebaseAuthRepo();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Providers cubits to app
      providers: [
        // auth cubit
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: _firebaseAuthRepo)..checkAuth(),
        ),
      ],

      // MaterialApp
      child: MaterialApp(
        title: 'Agenda de Salas',
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        /*
        Bloc Consumer that listens to AuthCubit state changes and rebuilds the UI accordingly.

        */
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            // unauthenticated state -> show AuthPage (login/register)
            if (state is Unauthenticated) {
              return const AuthPage();
            }
            //authenticated states
            if (state is Authenticated) {
              return const HomePage();
            } else {
              // loading...
              return const Center(child: CircularProgressIndicator());
            }
          },
          listener: (context, state) {
            if (state is AuthError) {
              // on auth error, show snackbar with error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
