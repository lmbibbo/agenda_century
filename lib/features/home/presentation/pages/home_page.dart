import 'package:agenda_century/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:agenda_century/features/auth/presentation/cubits/auth_states.dart';
import 'package:agenda_century/features/home/presentation/pages/show_calendar_list_page.dart';
import 'package:agenda_century/features/home/presentation/pages/show_calendar_page.dart';
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
  bool _showCalendarList = true;
  late CalendarService _calendarService;
  List<CalendarListEntry> _calendars = [];
  bool _loadingCalendars = false;
  CalendarListEntry? _selectedCalendar;

  void togglePages() {
    setState(() {
      _showCalendarList = !_showCalendarList;
    });
  }

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
        print('Access Token: $accessToken');
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
    } catch (e) {
      _showError('Error al cargar calendarios: $e');
    }
    setState(() => _loadingCalendars = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color.fromARGB(255, 201, 2, 2),
      ),
    );
  }

  // ✅ Esta función se llama cuando seleccionas un calendario
  void _onSelectCalendar(CalendarListEntry calendar) {
    setState(() {
      _selectedCalendar = calendar;
      _showCalendarList = false; // Cambiar a vista de calendario
    });

    // Opcional: Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Calendario seleccionado: ${calendar.summary ?? "Sin nombre"}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ✅ Esta función vuelve a la lista de calendarios
  void _onBackToList() {
    setState(() {
      _showCalendarList = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showCalendarList) {
      return ShowCalendarListPage(
        calendars: _calendars,
        onSelectCalendar: _onSelectCalendar,
      );
    } else {
      return ShowCalendarPage(
        calendarId: _selectedCalendar?.id ?? '',
        calendar: _selectedCalendar,
        togglePages: _onBackToList,
        calendarService: _calendarService,
      );
    }
  }
}
