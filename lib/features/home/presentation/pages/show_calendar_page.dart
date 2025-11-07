import 'package:flutter/material.dart';
import 'package:agenda_century/features/home/presentation/components/calendar_widget.dart';
import '../../services/calendar_service.dart';
import 'add_event_page.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import '../enumerations.dart';
import '../../../themes/theme_manager.dart';
import '../utils.dart';

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
  Mode _currentMode = Mode.day3Draggable;

  void _changeView(Mode newMode) {
    setState(() {
      _currentMode = newMode;
    });
    print('Vista cambiada a: ${newMode.text}');
  }

  void _changeThemeMode(ThemeMode newThemeMode) {
    setState(() {
      themeManager.setThemeMode(newThemeMode);
    });
    print('Modo de tema cambiado a: $newThemeMode');
  }

  List<Mode> _getMainModes() {
    return [Mode.agenda, Mode.day, Mode.day3Draggable];
  }

  List<Mode> _getAdditionalModes() {
    return Mode.values
        .where((mode) => !_getMainModes().contains(mode))
        .toList();
  }

  // Método para obtener el icono del tema actual
  IconData get _themeIcon {
    switch (themeManager.currentThemeMode) {
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
    return MaterialApp(
      locale: const Locale('es', 'ES'), // Establecer español como idioma
      theme: ThemeData.light(), // Tema claro
      darkTheme: ThemeData.dark(), // Tema oscuro
      themeMode: themeManager.currentThemeMode, // Modo actual del tema
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.calendar?.summary ?? 'Calendario'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.togglePages,
          ),
          actions: [
            // Botón para agregar evento
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddEventDialog(context),
              tooltip: 'Agregar evento',
            ),
            // Botón para cambiar el tema
            IconButton(
              icon: Icon(_themeIcon),
              onPressed: () {
                _showThemeModeDialog(context);
              },
              tooltip: 'Cambiar tema',
            ),

            // Botones para las vistas principales
            ..._getMainModes()
                .map(
                  (mode) => IconButton(
                    icon: Icon(
                      mode.icon,
                      color: _currentMode == mode
                          ? Colors.white
                          : Colors.white70,
                    ),
                    onPressed: () => _changeView(mode),
                    tooltip: mode.text,
                  ),
                )
                .toList(),

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
                          Icon(
                            mode.icon,
                            color: _currentMode == mode
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
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
      ),
    );
  }

  Widget _buildCalendarView() {
    return CustomCalendarView(
      calendarId: widget.calendarId,
      calendarService: widget.calendarService,
      eventsController: widget.eventsController,
      calendar: widget.calendar!,
      calendarMode: _currentMode,
      backgrouncolor: parseColor(widget.calendar!.backgroundColor!),
      calendarName: widget.calendar?.summary ?? 'Calendario',
    );
  }

void _showAddEventDialog(BuildContext context) async {
  print("Mostrando diálogo para agregar evento");
  final result = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AddEventPage(
        calendarId: widget.calendarId,
        calendarService: widget.calendarService,
        eventsController: widget.eventsController,
        backgrouncolor:  parseColor(widget.calendar!.backgroundColor!),
        initialDate: DateTime.now(), // O la fecha seleccionada en el calendario
        existingEvent: null, // Indica que es un nuevo evento
        calendarName: widget.calendar?.summary ?? 'Calendario',
      ),
    ),
  );

  if (result == true) {
    // Recargar eventos si se creó uno nuevo
    //widget.eventsController.updateCalendarData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento agregado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
  // Diálogo para seleccionar el modo del tema
  void _showThemeModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                ThemeMode.light,
                Icons.light_mode,
                'Modo claro',
                'Usar tema claro',
              ),
              _buildThemeOption(
                context,
                ThemeMode.dark,
                Icons.dark_mode,
                'Modo oscuro',
                'Usar tema oscuro',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode themeMode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final bool isSelected = themeManager.currentThemeMode == themeMode;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: () {
        _changeThemeMode(themeMode);
        Navigator.of(context).pop();
      },
      tileColor: isSelected
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

}
