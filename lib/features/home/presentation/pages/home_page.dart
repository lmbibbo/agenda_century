import 'package:agenda_century/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:agenda_century/features/auth/presentation/cubits/auth_states.dart';
import 'package:agenda_century/features/home/services/calendar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/calendar/v3.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CalendarService _calendarService;
  List<CalendarListEntry> _calendars = [];
  bool _loadingCalendars = false;
  bool _loadingEvents = false;
  String? _selectedCalendarId;
  
  @override
  void initState() {
    super.initState();
    _initializeCalendarService();
  }

  void _initializeCalendarService() {
    // Esperar a que el widget esté construido para acceder al context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AuthCubit>().state;
      if (state is Authenticated) {
        final accessToken = state.user.getAccessToken();
        if (accessToken != null) {
          _calendarService = CalendarService(userAccessToken: accessToken);
          _loadCalendars();
        }
      }
    });
  }

    Future<void> _loadCalendars() async {
    if (!mounted) return;
    
    setState(() => _loadingCalendars = true);
    try {
      _calendars = await _calendarService.getAvailableCalendars();
      if (_calendars.isNotEmpty) {
        _selectedCalendarId = _calendars.first.id;
       // _loadEvents(_calendars.first.id!);
      }
    } catch (e) {
      print('Error cargando calendarios: $e');
      _showError('Error al cargar calendarios: $e');
    }
    setState(() => _loadingCalendars = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color.fromARGB(0, 201, 2, 2),
      ),
    );
  }

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
                  icon: const Icon(Icons.logout),
                ),
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
                            style: TextStyle(fontWeight: FontWeight.bold),
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
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80),
                  const SizedBox(height: 20),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
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
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
