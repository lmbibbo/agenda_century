import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../services/calendar_service.dart';

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
  bool _loading = false;
  bool _refreshing = false;
  String _viewMode = 'semanal'; // 'diaria' o 'semanal'
  int _weekOffset = 0;
  int _dayOffset = 0;
  bool _dateFormatInitialized = false;

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
      setState(() {
        _dateFormatInitialized = true;
      });
      print(
        '_initializeDateFormatting: Formato de fechas inicializado correctamente',
      );
      _fetchEvents();
    } catch (e) {
      print(
        '_initializeDateFormatting: Error inicializando formato de fechas: $e',
      );
      // Fallback: intentar cargar eventos de todos modos
      _fetchEvents();
    }
  }

  Future<void> _fetchEvents() async {
    if (_refreshing) {
      print('_fetchEvents: Ya se está refrescando, ignorando llamada');
      return;
    }

    print('_fetchEvents: Iniciando carga de eventos');
    print(
      '_fetchEvents: _viewMode = $_viewMode, _weekOffset = $_weekOffset, _dayOffset = $_dayOffset',
    );

    setState(() {
      _loading = true;
      _refreshing = true;
    });

    try {
      DateTime timeMin;
      DateTime timeMax;

      if (_viewMode == 'diaria') {
        timeMin = _currentDay;
        timeMax = _currentDay.add(const Duration(days: 1));
      } else {
        timeMin = _weekStart;
        timeMax = _weekStart.add(const Duration(days: 7));
      }

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

      _debugEventTimes(events);

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

  // Agregar este método para debug
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

  DateTime get _weekStart {
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
              _buildNavigation(),
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

  Widget _buildNavigation() {
    print('_buildNavigation: Construyendo navegación (_viewMode: $_viewMode)');

    // Si no se ha inicializado el formato de fechas, mostrar un placeholder
    if (!_dateFormatInitialized) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Cargando...',
            style: TextStyle(color: Color(0xFF5f6368)),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón anterior
          IconButton(
            onPressed: () {
              setState(() {
                if (_viewMode == 'diaria') {
                  _dayOffset--;
                } else {
                  _weekOffset--;
                }
              });
              _fetchEvents();
            },
            icon: const Icon(Icons.chevron_left, color: Color(0xFF5f6368)),
          ),

          // Etiqueta
          Expanded(
            child: Center(
              child: Text(
                _viewMode == 'diaria'
                    ? _getFormattedDay()
                    : _getFormattedWeek(),
                style: const TextStyle(
                  color: Color(0xFF202124),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Botón siguiente
          IconButton(
            onPressed: () {
              setState(() {
                if (_viewMode == 'diaria') {
                  _dayOffset++;
                } else {
                  _weekOffset++;
                }
              });
              _fetchEvents();
            },
            icon: const Icon(Icons.chevron_right, color: Color(0xFF5f6368)),
          ),
        ],
      ),
    );
  }

  String _getFormattedDay() {
    try {
      return DateFormat('EEEE, d MMM', 'es_ES').format(_currentDay);
    } catch (e) {
      print('_getFormattedDay: Error formateando día: $e');
      return DateFormat(
        'EEEE, d MMM',
      ).format(_currentDay); // Fallback sin locale
    }
  }

  String _getFormattedWeek() {
    try {
      return 'Semana del ${DateFormat('d MMM', 'es_ES').format(_weekDays[0])} al ${DateFormat('d MMM', 'es_ES').format(_weekDays[6])}';
    } catch (e) {
      print('_getFormattedWeek: Error formateando semana: $e');
      return 'Semana del ${DateFormat('d MMM').format(_weekDays[0])} al ${DateFormat('d MMM').format(_weekDays[6])}'; // Fallback sin locale
    }
  }

  Widget _buildSubtitle() {
    print('_buildSubtitle: Construyendo subtítulo');
    return const Text(
      'Próximos eventos:',
      style: TextStyle(
        color: Color(0xFF007AFF),
        fontSize: 18,
        fontWeight: FontWeight.bold,
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
      onRefresh: _fetchEvents,
      color: const Color(0xFF1a73e8),
      child: _viewMode == 'diaria' ? _buildDailyView() : _buildWeeklyView(),
    );
  }

  Widget _buildDailyView() {
    print(
      '_buildDailyView: Construyendo vista diaria con ${_filteredEvents.length} eventos',
    );
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getFormattedDay(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202124),
                ),
              ),
              const SizedBox(height: 16),
              ..._filteredEvents.map(_buildEventItem).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyView() {
    print(
      '_buildWeeklyView: Construyendo vista semanal con ${_filteredEvents.length} eventos',
    );
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Encabezado de días
          _buildWeekHeader(),
          Expanded(child: _buildWeeklyCalendar()),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: Color(0xFFdddddd), width: 1.0),
            right: BorderSide(color: Color(0xFFdddddd), width: 1.0),
          ),
        ),
        child: Column(
          children: [
            // Grid de tiempo con eventos
            Container(
              height: _hourSlots.length * 40.0,
              child: Stack(
                children: [
                  // Grid de fondo (horas)
                  _buildTimeGrid(),
                  // Eventos posicionados absolutamente
                  ..._buildAllEvents(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeGrid() {
    return Column(
      children: _hourSlots.map((slot) {
        return _buildTimeSlotRow(slot);
      }).toList(),
    );
  }

  List<Widget> _buildAllEvents() {
    final eventWidgets = <Widget>[];

    for (final event in _filteredEvents) {
      final eventStart = event.start?.dateTime?.toLocal();
      if (eventStart == null) continue;

      // Encontrar en qué día de la semana cae el evento
      final dayIndex = _weekDays.indexWhere(
        (day) =>
            day.year == eventStart.year &&
            day.month == eventStart.month &&
            day.day == eventStart.day,
      );

      if (dayIndex >= 0) {
        final position = _calculateEventPosition(event, dayIndex);
        if (position != null) {
          eventWidgets.add(
            Positioned(
              left: position['left'],
              top: position['top'],
              width: position['width'],
              height: position['height'],
              child: _buildWeeklyEventItem(event),
            ),
          );
        }
      }
    }

    print('_buildAllEvents: ${eventWidgets.length} widgets de eventos creados');
    return eventWidgets;
  }

  Map<String, double>? _calculateEventPosition(gcal.Event event, int dayIndex) {
    final eventStart = event.start?.dateTime?.toLocal();
    final eventEnd = event.end?.dateTime?.toLocal();

    if (eventStart == null || eventEnd == null) return null;

    // Calcular posición horizontal
    final dayColumnWidth = (MediaQuery.of(context).size.width - 80) / 7;
    final left = 60.0 + (dayIndex * dayColumnWidth) + 2.0; // +2 para margen

    // Calcular posición vertical basada en la hora
    final startHour = eventStart.hour + (eventStart.minute / 60.0);
    final endHour = eventEnd.hour + (eventEnd.minute / 60.0);
    final durationHours = endHour - startHour;

    final baseHour = 6.0; // ← CAMBIAR de 6.0 a 7.0
    final pixelsPerHour = 160.0; // ← CAMBIAR de 160.0 a 120.0
    final top = (startHour - baseHour) * pixelsPerHour;
    final height = durationHours * pixelsPerHour;

    // Asegurar que la altura mínima sea visible
    final minHeight = 20.0;
    final adjustedHeight = height < minHeight ? minHeight : height;

    return {
      'left': left,
      'top': top,
      'width': dayColumnWidth - 4.0, // -4 para márgenes
      'height': adjustedHeight,
    };
  }

  Widget _buildWeeklyEventItem(gcal.Event event) {
    final isPast = event.end?.dateTime?.isBefore(DateTime.now()) ?? false;
    final eventStart = event.start?.dateTime?.toLocal();
    final eventEnd = event.end?.dateTime?.toLocal();

    String formatTime(DateTime? dateTime) {
      if (dateTime == null) return '';
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isPast ? const Color(0xFFf0f0f0) : const Color(0xFFe6f2ff),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isPast ? const Color(0xFF999999) : const Color(0xFF007AFF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.summary ?? 'Evento',
            style: TextStyle(
              fontSize: 10,
              color: isPast ? const Color(0xFF666666) : const Color(0xFF333333),
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          if (eventStart != null && eventEnd != null)
            Text(
              '${formatTime(eventStart)} - ${formatTime(eventEnd)}', // ← MEJORADO: mostrar hora inicio y fin
              style: TextStyle(
                fontSize: 8,
                color: isPast
                    ? const Color(0xFF888888)
                    : const Color(0xFF007AFF),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader() {
    print('_buildWeekHeader: Construyendo encabezado de semana');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFdddddd), width: 1.0),
          top: BorderSide(color: Color(0xFFdddddd), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Celda de hora con borde derecho
          Container(
            width: 60,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFFdddddd), width: 1.0),
              ),
            ),
            child: const Text(
              'Hora',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),

          // Días de la semana con bordes verticales
          ..._weekDays.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isToday =
                day.day == DateTime.now().day &&
                day.month == DateTime.now().month &&
                day.year == DateTime.now().year;

            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xFFb3e0ff)
                      : const Color(0xFFf8f8f8),
                  border: Border(
                    right: index < 6
                        ? const BorderSide(color: Color(0xFFdddddd), width: 1.0)
                        : BorderSide.none, // Última columna sin borde derecho
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEE', 'es_ES').format(day),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      DateFormat('d', 'es_ES').format(day),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeSlotRow(Map<String, int> slot) {
    final showHourLabel = slot['minutes'] == 0;

    return Container(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna de horas - SIN BORDES HORIZONTALES
          Container(
            width: 60,
            padding: const EdgeInsets.only(right: 8),
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFFdddddd), width: 1.0),
              ),
            ),
            child: showHourLabel
                ? Container(
                    // Este contenedor ayuda a alinear el texto con la línea
                    margin: const EdgeInsets.only(
                      top: -4,
                    ), // Ajusta este valor según necesites
                    child: Text(
                      '${slot['hour']!.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),

          // Columnas de días - CON BORDES HORIZONTALES
          ...List.generate(7, (index) {
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: slot['minutes'] == 0
                        ? const BorderSide(
                            color: Color(0xFFdddddd),
                            width: 1.0,
                          ) // Línea más gruesa cada hora
                        : const BorderSide(
                            color: Color(0xFFf0f0f0),
                            width: 0.5,
                          ), // Línea sutil cada 30 min
                    right: BorderSide(
                      color: const Color(0xFFdddddd),
                      width: index == 6
                          ? 0.0
                          : 1.0, // Sin borde derecho en la última columna
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Map<String, int>> get _hourSlots {
    final startHour = 6; // Comienza a las 6:00
    final endHour = 22; // Termina a las 22:00
    final totalHours = endHour - startHour;
    final totalSlots = totalHours * 4;

    final slots = List.generate(totalSlots, (index) {
      final hour = startHour + (index ~/ 4);
      final minutes = (index % 4) * 15;
      return {'hour': hour, 'minutes': minutes};
    });
    print(
      '_hourSlots: Generados ${slots.length} slots horarios (de $startHour:00 a $endHour:00)',
    );
    return slots;
  }

  List<gcal.Event> _getEventsForTimeSlot(DateTime day, Map<String, int> slot) {
    final slotStart = DateTime(
      day.year,
      day.month,
      day.day,
      slot['hour']!,
      slot['minutes']!,
    );
    final slotEnd = slotStart.add(const Duration(minutes: 15));

    return _filteredEvents.where((event) {
      final eventStart = event.start?.dateTime;
      final eventEnd = event.end?.dateTime;

      if (eventStart == null || eventEnd == null) return false;

      // Verificar si el evento se superpone con este slot de 15 minutos
      return (eventStart.isBefore(slotEnd) && eventEnd.isAfter(slotStart));
    }).toList();
  }

  Map<String, dynamic> _getEventPosition(gcal.Event event, DateTime day) {
    final eventStart = event.start?.dateTime;
    final eventEnd = event.end?.dateTime;

    if (eventStart == null || eventEnd == null) {
      return {'height': 40, 'top': 0, 'span': 1};
    }

    // Calcular duración en minutos
    final duration = eventEnd.difference(eventStart).inMinutes;

    // Calcular posición vertical basada en la hora de inicio
    final startMinutes = eventStart.hour * 60 + eventStart.minute;
    final startSlot =
        (startMinutes - (6 * 60)) / 15; // Restar 6 AM (hora de inicio)

    // Altura en slots de 15 minutos (mínimo 1 slot = 15 minutos)
    final span = (duration / 15).ceil().clamp(1, 1000);

    return {
      'height': span * 40, // 40px por slot de 15 minutos
      'top': startSlot * 40,
      'span': span,
    };
  }

  Widget _buildEventCell(List<gcal.Event> events, DateTime slotTime) {
    if (events.isEmpty) {
      return Container();
    }

    // Ordenar eventos por hora de inicio
    events.sort(
      (a, b) => (a.start?.dateTime ?? DateTime.now()).compareTo(
        b.end?.dateTime ?? DateTime.now(),
      ),
    );

    final event = events.first; // Mostrar solo el primer evento por simplicidad
    final isPast = event.end?.dateTime?.isBefore(DateTime.now()) ?? false;

    return Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isPast ? const Color(0xFFf0f0f0) : const Color(0xFFe6f2ff),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isPast ? const Color(0xFF999999) : const Color(0xFF007AFF),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            event.summary ?? 'Evento',
            style: TextStyle(
              fontSize: 9,
              color: isPast ? const Color(0xFF666666) : const Color(0xFF333333),
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          if (event.start?.dateTime != null)
            Text(
              DateFormat('HH:mm').format(event.start!.dateTime!),
              style: TextStyle(
                fontSize: 8,
                color: isPast
                    ? const Color(0xFF888888)
                    : const Color(0xFF007AFF),
              ),
            ),
        ],
      ),
    );
  }

  // En _buildEventItem, actualiza el formato de hora:
  Widget _buildEventItem(gcal.Event event) {
    final isPast = event.end?.dateTime?.isBefore(DateTime.now()) ?? false;
    final start = event.start?.dateTime;
    final end = event.end?.dateTime;

    print(
      '_buildEventItem: Construyendo evento - ${event.summary} (pasado: $isPast)',
    );

    String formatTime(DateTime? dateTime) {
      if (dateTime == null) return '';
      try {
        return DateFormat('HH:mm').format(dateTime);
      } catch (e) {
        print('formatTime: Error formateando hora: $e');
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isPast ? const Color(0xFFf0f0f0) : const Color(0xFFe6f2ff),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isPast ? const Color(0xFF999999) : const Color(0xFF007AFF),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.summary ?? 'Sin título',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          if (start != null && end != null)
            Text(
              '${formatTime(start)} - ${formatTime(end)}',
              style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
            ),
        ],
      ),
    );
  }

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
