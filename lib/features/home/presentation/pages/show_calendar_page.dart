import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../services/calendar_service.dart';
import 'package:calendar_view/calendar_view.dart';

class ShowCalendarPage extends StatefulWidget {
  final void Function()? togglePages;
  final String calendarId;
  final gcal.CalendarListEntry? calendar;
  final CalendarService calendarService; // Recibir el servicio

  const ShowCalendarPage({
    super.key,
    this.togglePages,
    required this.calendarId,
    this.calendar,
    required this.calendarService,
  });

  @override
  State<ShowCalendarPage> createState() => _ShowCalendarPageState();
}

class _ShowCalendarPageState extends State<ShowCalendarPage> {
  List<gcal.Event> _events = [];
  List<CalendarEventData> get _eventsData {
    return _events.map((event) {
      final start =
          event.start?.dateTime?.toLocal() ?? event.start?.date?.toLocal();
      final end = event.end?.dateTime?.toLocal() ?? event.end?.date?.toLocal();
      return CalendarEventData(
        date: start!,
        title: event.summary ?? 'Evento',
        startTime: start,
        endTime: end!,
        description: event.description ?? '',
      );
    }).toList();
  }
  DateTime now = DateTime.now();
  bool _loading = false;
  bool _refreshing = false;
  String _viewMode = 'semanal'; // 'diaria' o 'semanal'
/*  int _weekOffset = 0;
  int _dayOffset = 0;
  bool _dateFormatInitialized = false;
*/
  @override
  void initState() {
    super.initState();
    print('ShowCalendarPage: initState llamado');
    print('ShowCalendarPage: calendarId = ${widget.calendarId}');
    print(
      'ShowCalendarPage: calendar name = ${widget.calendar?.summary ?? "N/A"}',
    );

    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    try {
      print(
        '_initializeDateFormatting: Inicializando formato de fechas para español',
      );
      await initializeDateFormatting('es_ES');
     /* setState(() {
        _dateFormatInitialized = true;
      });
      print(
        '_initializeDateFormatting: Formato de fechas inicializado correctamente',
      );*/
      _fetchEvents(now.subtract(Duration(days: 7)), 15);
    } catch (e) {
      print(
        '_initializeDateFormatting: Error inicializando formato de fechas: $e',
      );
      // Fallback: intentar cargar eventos de todos modos
      _fetchEvents(now.subtract(Duration(days: 7)), 15);
    }
  }

  Future<void> _fetchEvents(DateTime date, int days) async {
    if (_refreshing) {
      print('_fetchEvents: Ya se está refrescando, ignorando llamada');
      return;
    }

    print('_fetchEvents: Iniciando carga de eventos');

    setState(() {
      _loading = true;
      _refreshing = true;
    });

    try {
      DateTime timeMin;
      DateTime timeMax;

      timeMin = date;
      timeMax = timeMin.add(Duration(days: days));

      // Ajustar horas
      timeMin = DateTime(timeMin.year, timeMin.month, timeMin.day, 7, 0, 0, 0);
      timeMax = DateTime(timeMax.year, timeMax.month, timeMax.day, 21, 0, 0, 0);

      print('_fetchEvents: timeMin: $timeMin, timeMax: $timeMax');

      // Usar el servicio para obtener eventos
      final events = await widget.calendarService.getEvents(
        calendarId: widget.calendarId,
        timeMin: timeMin,
        timeMax: timeMax,
        maxResults: 100,
        singleEvents: true,
        orderBy: 'startTime',
      );

      _eventsData.clear();
      /*
      _eventsData.addAll(events.map((event) {
        final start =
            event.start?.dateTime?.toLocal() ?? event.start?.date?.toLocal();
        final end =
            event.end?.dateTime?.toLocal() ?? event.end?.date?.toLocal();
        return CalendarEventData(
          date: start!,
          title: event.summary ?? 'Evento',
          startTime: start,
          endTime: end!,
          description: event.description ?? '',
        );
      }));
*/
      for (var event in events) {
        if (event.start == null || event.end == null) {
          print(
            '_fetchEvents: Evento sin fecha de inicio o fin - ${event.summary}',
          );
          continue;
        }
        final start =
            event.start?.dateTime?.toLocal() ?? event.start?.date?.toLocal();
        final end =
            event.end?.dateTime?.toLocal() ?? event.end?.date?.toLocal();
        CalendarEventData eventData = CalendarEventData(
          date: start!,
          title: event.summary ?? 'Evento',
          startTime: start,
          endTime: end!,
          description: event.description ?? '',
        );
        _eventsData.add(eventData);
      }

      if (!mounted) return;
      CalendarControllerProvider.of(context).controller.addAll(_eventsData);

      setState(() {
        _events = events;
      });

      print('_fetchEvents: ${_events.length} eventos cargados exitosamente');
      for (var event in _events) {
        print('  - ${event.summary} (${event.start?.dateTime})');
      }
    } catch (e) {
      print('_fetchEvents: Error fetching events: $e');
      // Mostrar error al usuario
      _showErrorDialog('Error al cargar eventos: $e');
      setState(() {
        _events = [];
      });
    } finally {
      print('_fetchEvents: Finalizando carga, actualizando estado');
      setState(() {
        _loading = false;
        _refreshing = false;
      });
    }
  }

/*  // Agregar este método para debug
  void _debugEventTimes(List<gcal.Event> events) {
    print('=== DEBUG EVENT TIMES ===');
    for (var event in events) {
      final start = event.start?.dateTime;
      final end = event.end?.dateTime;
      final startLocal = start?.toLocal();
      final endLocal = end?.toLocal();

      print('Event: ${event.summary}');
      print('  Original: ${start} - ${end}');
      print('  Local: ${startLocal} - ${endLocal}');
      print('  Hour (local): ${startLocal?.hour}:${startLocal?.minute}');
    }
    print('========================');
  }
*/
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

/*  DateTime get _weekStart {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final result = start.add(Duration(days: _weekOffset * 7));
    print('_weekStart: Calculado como $result (_weekOffset = $_weekOffset)');
    return result;
  }

  DateTime get _currentDay {
    final result = DateTime.now().add(Duration(days: _dayOffset));
    print('_currentDay: Calculado como $result (_dayOffset = $_dayOffset)');
    return result;
  }

  List<DateTime> get _weekDays {
    final days = List.generate(
      7,
      (index) => _weekStart.add(Duration(days: index)),
    );
    print('_weekDays: Generada semana con ${days.length} días');
    return days;
  }

  List<gcal.Event> get _filteredEvents {
    final now = DateTime.now();
    final filtered = _events.where((event) {
      final start =
          event.start?.dateTime?.toLocal() ?? event.start?.date?.toLocal();
      if (start == null) {
        print('_filteredEvents: Evento sin fecha de inicio - ${event.summary}');
        return false;
      }

      final startDate = start;

      if (_viewMode == 'diaria') {
        final matches =
            startDate.year == _currentDay.year &&
            startDate.month == _currentDay.month &&
            startDate.day == _currentDay.day;
        if (matches) {
          print('_filteredEvents: Evento incluido (diario) - ${event.summary}');
        }
        return matches;
      } else {
        final endOfWeek = _weekStart.add(const Duration(days: 7));
        final matches =
            startDate.isAfter(_weekStart) && startDate.isBefore(endOfWeek);
        if (matches) {
          print(
            '_filteredEvents: Evento incluido (semanal) - ${event.summary}',
          );
        }
        return matches;
      }
    }).toList();

    print(
      '_filteredEvents: ${filtered.length} eventos filtrados de ${_events.length} totales',
    );
    return filtered;
  }
*/
  @override
  Widget build(BuildContext context) {
    print(
      'build: Reconstruyendo widget (_loading: $_loading, _events: ${_events.length})',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 16),

              // Selector de vista y botón agregar
              _buildActionsRow(),
              const SizedBox(height: 16),

              // Navegación semanal/diaria
              //  _buildNavigation(),
              const SizedBox(height: 16),

              // Subtítulo
              //_buildSubtitle(),
              //const SizedBox(height: 10),

              // Vista del calendario
              Expanded(child: _buildCalendarView()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventModal,
        backgroundColor: const Color(0xFF1a73e8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    print('_buildHeader: Construyendo header');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botón volver
        GestureDetector(
          onTap: () {
            print('_buildHeader: Botón volver presionado');
            widget.togglePages?.call();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Color(0xFF1a73e8), size: 20),
                SizedBox(width: 4),
                Text(
                  'Volver',
                  style: TextStyle(
                    color: Color(0xFF1a73e8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Título
        Expanded(
          child: Text(
            'Calendario: ${widget.calendar?.summary ?? 'Sin nombre'}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF202124),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Espacio para alineación
        const SizedBox(width: 80),
      ],
    );
  }

  Widget _buildActionsRow() {
    print('_buildActionsRow: Construyendo fila de acciones');
    return Row(
      children: [
        // Selector de vista
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [_buildViewButton('diaria'), _buildViewButton('semanal')],
          ),
        ),

        const Spacer(),

        // Botón agregar evento
        ElevatedButton(
          onPressed: _showAddEventModal,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1a73e8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Row(
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 4),
              Text('Evento', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewButton(String mode) {
    final isSelected = _viewMode == mode;
    print(
      '_buildViewButton: Construyendo botón para $mode (seleccionado: $isSelected)',
    );

    return GestureDetector(
      onTap: () {
        print('_buildViewButton: Cambiando vista a $mode');
        setState(() => _viewMode = mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1a73e8) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          mode == 'diaria' ? 'Día' : 'Semana',
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF5f6368),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    print(
      '_buildCalendarView: Construyendo vista de calendario (_loading: $_loading, _events: ${_events.length})',
    );

    if (_loading && _events.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1a73e8)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchEvents(now.subtract(Duration(days: 7)), 15),
      color: const Color(0xFF1a73e8),
      child: _viewMode == 'diaria' ? _buildDailyView() : _buildWeeklyView(),
    );
  }

  Widget _buildDailyView() {
    return Scaffold(
      body: DayView(
        startHour: 7,
        endHour: 22,
        onPageChange: (date, viewType) => _fetchEvents(date, 1),
      ),
    );
  }

  /*
  void dayPageChange(DateTime date) {
    print('dayPageChange: Página cambiada a $date');
    final newDayOffset = date.difference(DateTime.now()).inDays;
    if (newDayOffset != _dayOffset) {
      setState(() {
        _dayOffset = newDayOffset;
      });
      _fetchEvents();
    }
  }
*/
  Widget _buildWeeklyView() {
    return Scaffold(
      body: WeekView(
        startHour: 7,
        endHour: 22,
        //onPageChange: (date, viewType) => _fetchEvents(date, 7),
      ),
    );
  }

  /*
  void weekPageChange(DateTime date) {
    print('weekPageChange: Página cambiada a $date');
    final newWeekOffset = ((date.difference(DateTime.now()).inDays + 1) / 7).floor() + 1;
    if (newWeekOffset != _weekOffset) {
      setState(() {
        _weekOffset = newWeekOffset;
      });
      _fetchEvents();
    }
  }
*/
  void _showAddEventModal() {
    print('_showAddEventModal: Mostrando modal para agregar evento');
    // TODO: Implementar modal para agregar evento
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Evento'),
        content: const Text('Funcionalidad para agregar eventos pronto...'),
        actions: [
          TextButton(
            onPressed: () {
              print('_showAddEventModal: Cerrando modal');
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
