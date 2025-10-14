import 'package:agenda_century/features/auth/data/firebase_auth_repo.dart';
import 'package:agenda_century/features/auth/presentation/components/loading.dart';
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
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'features/themes/theme_manager.dart';

var currentThemeMode = ThemeMode.system; // Modo por defecto: sistema

void main() async {
  // firebase setup
  Intl.defaultLocale = 'es_ES';
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // run app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _firebaseAuthRepo = FirebaseAuthRepo();
  final EventsController _eventsController = EventsController();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: _firebaseAuthRepo)..checkAuth(),
        ),
      ],
      // ❌ ELIMINAR CalendarControllerProvider - NO EXISTE en infinite_calendar_view
      child: MaterialApp(
        title: 'Agenda de Salas',
        localizationsDelegates: const [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        themeMode: themeManager.currentThemeMode,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Unauthenticated) {
              return const AuthPage();
            }
            if (state is Authenticated) {
              // Pasar el EventsController al HomePage
              return HomePage(eventsController: _eventsController);
            } else {
              return const LoadingScreen();
            }
          },
          listener: (context, state) {
            if (state is AuthError) {
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