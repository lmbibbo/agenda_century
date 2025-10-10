import 'package:flutter/material.dart';
import 'package:agenda_century/features/home/presentation/components/calendar_widget.dart';
import 'package:agenda_century/features/home/services/calendar_service.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import '../enumerations.dart'; // Importar el enum Mode

class ShowCalendarPage extends StatefulWidget {
  final String calendarId;
  final gcal.CalendarListEntry? calendar;
  final VoidCallback togglePages;
  final CalendarService calendarService;
  final EventsController eventsController;

  const ShowCalendarPage({
    super.key,
    required this.calendarId,
    required this.calendar,
    required this.togglePages,
    required this.calendarService,
    required this.eventsController,
  });

  @override
  State<ShowCalendarPage> createState() => _ShowCalendarPageState();
}

class _ShowCalendarPageState extends State<ShowCalendarPage> {
  Mode _currentMode = Mode.day3Draggable; // Valor por defecto - puedes cambiarlo
  ThemeMode _currentThemeMode = ThemeMode.system; // Valor por defecto

  void _changeView(Mode newMode) {
    setState(() {
      _currentMode = newMode;
    });
    // Aquí puedes añadir lógica adicional si es necesario
    print('Vista cambiada a: ${newMode.text}');
  }

  void _changeThemeMode(ThemeMode newThemeMode) {
    setState(() {
      _currentThemeMode = newThemeMode;
    });
    print('Modo de tema cambiado a: $newThemeMode');
  }

  // Método para obtener las vistas principales (para no saturar la AppBar)
  List<Mode> _getMainModes() {
    return [
      Mode.agenda,
      Mode.day,
      Mode.day3Draggable,
      Mode.day7,
    ];
  }

  // Método para obtener las vistas adicionales
  List<Mode> _getAdditionalModes() {
    return Mode.values.where((mode) => !_getMainModes().contains(mode)).toList();
  }

  // Método para obtener el icono del tema actual
  IconData get _themeIcon {
    switch (_currentThemeMode) {
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.calendar?.summary ?? 'Calendario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.togglePages,
        ),
        actions: [
          // Botones para las vistas principales
          ..._getMainModes().map((mode) => 
            IconButton(
              icon: Icon(mode.icon,
                  color: _currentMode == mode 
                      ? Colors.white 
                      : Colors.white70),
              onPressed: () => _changeView(mode),
              tooltip: mode.text,
            ),
          ).toList(),
          
          // Menú desplegable para las vistas adicionales
          PopupMenuButton<Mode>(
            icon: Icon(Icons.more_vert),
            onSelected: _changeView,
            tooltip: 'Más vistas',
            itemBuilder: (BuildContext context) => 
                _getAdditionalModes().map((Mode mode) {
              return PopupMenuItem<Mode>(
                value: mode,
                child: Row(
                  children: [
                    Icon(mode.icon,
                         color: _currentMode == mode 
                             ? Theme.of(context).primaryColor 
                             : null),
                    const SizedBox(width: 12),
                    Text(mode.text),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _buildCalendarView(),
    );
  }

  Widget _buildCalendarView() {
    return CustomCalendarView(
      calendarId: widget.calendarId,
      calendarService: widget.calendarService,
      eventsController: widget.eventsController,
      calendarMode: _currentMode, // Pasar el modo actual al calendario
    );
  }
}