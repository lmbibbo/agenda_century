import 'package:agenda_century/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:agenda_century/features/auth/presentation/cubits/auth_states.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  
// CalendarList _calendarList = CalendarList();

 @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Verificar si el estado es Authenticated y obtener el usuario
        if (state is Authenticated) {
          final user = state.user;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Home Page'),
              actions: [
                // logout Button
                IconButton(
                  onPressed: () {
                    final authCubit = context.read<AuthCubit>();
                    authCubit.logout();
                  },
                  icon: const Icon(Icons.logout)
                )
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                  // Mensaje de bienvenida con nombre
                  Text(
                    '¡Bienvenido/a!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Nombre del usuario
                  Text(
                    user.name ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  // Email del usuario
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // ID del usuario (opcional)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text(
                            'Información de cuenta:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'UID: ${user.getAccessToken()}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Botones adicionales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Acción para ver perfil
                        },
                        icon: const Icon(Icons.person),
                        label: const Text('Mi Perfil'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Acción para configuraciones
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('Ajustes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else if (state is AuthError) {
          // Manejar estado de error
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,                    
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthCubit>().checkAuth();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Estado de carga o no autenticado
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
