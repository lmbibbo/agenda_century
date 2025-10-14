import 'package:agenda_century/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:agenda_century/features/auth/presentation/cubits/auth_states.dart';
import 'package:agenda_century/features/home/presentation/components/calendar_widget.dart';
import 'package:agenda_century/features/home/presentation/pages/show_calendar_list_page.dart';
import 'package:agenda_century/features/home/presentation/pages/show_calendar_page.dart';
import 'package:agenda_century/features/home/services/calendar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

class HomePage extends StatefulWidget {
  final EventsController eventsController;
  
  const HomePage({super.key, required this.eventsController});

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

  void _onSelectCalendar(CalendarListEntry calendar) {
    setState(() {
      _selectedCalendar = calendar;
      _showCalendarList = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Calendario seleccionado: ${calendar.summary ?? "Sin nombre"}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
       // summary: _selectedCalendar!.summary ?? 'Calendario ',
        togglePages: _onBackToList,
        calendarService: _calendarService,
        eventsController: widget.eventsController, // Pasar el controller
      );
    }
  }
}