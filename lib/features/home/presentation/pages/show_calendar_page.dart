import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ShowCalendarPage extends StatefulWidget {
  final void Function()? togglePages;
  final String calendarId;
  final CalendarListEntry? calendar;

  const ShowCalendarPage({ 
    super.key, 
    this.togglePages, 
    required this.calendarId,
    this.calendar,
  });

  @override
  State<ShowCalendarPage> createState() => _ShowCalendarPageState();
}

class _ShowCalendarPageState extends State<ShowCalendarPage> {
  List<Event> _events = [];
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
    print('ShowCalendarPage: calendar name = ${widget.calendar?.summary ?? "N/A"}');

    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    try {
      print('_initializeDateFormatting: Inicializando formato de fechas para español');
      await initializeDateFormatting('es_ES');
      setState(() {
        _dateFormatInitialized = true;
      });
      print('_initializeDateFormatting: Formato de fechas inicializado correctamente');
      _fetchEvents();
    } catch (e) {
      print('_initializeDateFormatting: Error inicializando formato de fechas: $e');
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
    print('_fetchEvents: _viewMode = $_viewMode, _weekOffset = $_weekOffset, _dayOffset = $_dayOffset');
    
    setState(() {
      _loading = true;
      _refreshing = true;
    });

    try {
      // TODO: Implementar la llamada a la API de Google Calendar
      // Similar a tu función fetchEvents en React Native
      print('_fetchEvents: Simulando llamada a API...');
      await Future.delayed(const Duration(seconds: 1)); // Simulación
      
      // Ejemplo de datos mock
      _events = [
        Event(
          id: '1',
          summary: 'Reunión de equipo',
          start: EventDateTime(
            dateTime: DateTime.now().add(const Duration(hours: 2)),
          ),
          end: EventDateTime(
            dateTime: DateTime.now().add(const Duration(hours: 3)),
          ),
        ),
        Event(
          id: '2',
          summary: 'Almuerzo con cliente',
          start: EventDateTime(
            dateTime: DateTime.now().add(const Duration(days: 1)),
          ),
          end: EventDateTime(
            dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
          ),
        ),
      ];
      
      print('_fetchEvents: ${_events.length} eventos cargados exitosamente');
      for (var event in _events) {
        print('  - ${event.summary} (${event.start?.dateTime})');
      }
    } catch (e) {
      print('_fetchEvents: Error fetching events: $e');
    } finally {
      print('_fetchEvents: Finalizando carga, actualizando estado');
      setState(() {
        _loading = false;
        _refreshing = false;
      });
    }
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
    final days = List.generate(7, (index) => 
      _weekStart.add(Duration(days: index))
    );
    print('_weekDays: Generada semana con ${days.length} días');
    return days;
  }

  List<Map<String, int>> get _hourSlots {
    final slots = List.generate(28, (index) {
      final hour = 7 + (index ~/ 2);
      final minutes = (index % 2) * 30;
      return {'hour': hour, 'minutes': minutes};
    });
    print('_hourSlots: Generados ${slots.length} slots horarios');
    return slots;
  }

  List<Event> get _filteredEvents {
    final now = DateTime.now();
    final filtered = _events.where((event) {
      final start = event.start?.dateTime ?? event.start?.date;
      if (start == null) {
        print('_filteredEvents: Evento sin fecha de inicio - ${event.summary}');
        return false;
      }

      final startDate =  start;

      if (_viewMode == 'diaria') {
        final matches = startDate.year == _currentDay.year &&
               startDate.month == _currentDay.month &&
               startDate.day == _currentDay.day;
        if (matches) {
          print('_filteredEvents: Evento incluido (diario) - ${event.summary}');
        }
        return matches;
      } else {
        final endOfWeek = _weekStart.add(const Duration(days: 7));
        final matches = startDate.isAfter(_weekStart) && startDate.isBefore(endOfWeek);
        if (matches) {
          print('_filteredEvents: Evento incluido (semanal) - ${event.summary}');
        }
        return matches;
      }
    }).toList();
    
    print('_filteredEvents: ${filtered.length} eventos filtrados de ${_events.length} totales');
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    print('build: Reconstruyendo widget (_loading: $_loading, _events: ${_events.length})');
    
    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 15),
              
              // Selector de vista y botón agregar
              _buildActionsRow(),
              const SizedBox(height: 10),
              
              // Navegación semanal/diaria
              _buildNavigation(),
              const SizedBox(height: 10),
              
              // Subtítulo
              _buildSubtitle(),
              const SizedBox(height: 10),
              
              // Vista del calendario
              Expanded(
                child: _buildCalendarView(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventModal,
        backgroundColor: const Color(0xFF007AFF),
        child: const Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255)),
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
            padding: const EdgeInsets.all(10),
            child: const Text(
              '← Volver',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // Título
        Expanded(
          child: Text(
            'Calendario: ${widget.calendar?.summary ?? 'Sin nombre'}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
            color: const Color(0xFFe0e0e0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildViewButton('diaria'),
              _buildViewButton('semanal'),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Botón agregar evento
        ElevatedButton(
          onPressed: () {
            print('_buildActionsRow: Botón + Evento presionado');
            _showAddEventModal();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            '+ Evento',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewButton(String mode) {
    final isSelected = _viewMode == mode;
    print('_buildViewButton: Construyendo botón para $mode (seleccionado: $isSelected)');
    
    return GestureDetector(
      onTap: () {
        print('_buildViewButton: Cambiando vista a $mode');
        setState(() => _viewMode = mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(0, 0, 132, 255) : Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          mode == 'diaria' ? 'Diaria' : 'Semanal',
          style: TextStyle(
            color: isSelected ? Color.fromARGB(255, 255, 255, 255) : const Color(0xFF333333),
            fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFe0e0e0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: null, // Deshabilitado hasta que se inicialice
              icon: const Icon(Icons.arrow_back, color: Color(0xFF999999)),
            ),
            const Text(
              'Cargando...',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: null, // Deshabilitado hasta que se inicialice
              icon: const Icon(Icons.arrow_forward, color: Color(0xFF999999)),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFe0e0e0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón anterior
          IconButton(
            onPressed: () {
              print('_buildNavigation: Botón anterior presionado');
              setState(() {
                if (_viewMode == 'diaria') {
                  _dayOffset--;
                  print('_buildNavigation: _dayOffset decrementado a $_dayOffset');
                } else {
                  _weekOffset--;
                  print('_buildNavigation: _weekOffset decrementado a $_weekOffset');
                }
              });
              _fetchEvents();
            },
            icon: const Icon(Icons.arrow_back, color: Color(0xFF007AFF)),
          ),
          
          // Etiqueta
          Text(
            _viewMode == 'diaria'
                ? _getFormattedDay()
                : _getFormattedWeek(),
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Botón siguiente
          IconButton(
            onPressed: () {
              print('_buildNavigation: Botón siguiente presionado');
              setState(() {
                if (_viewMode == 'diaria') {
                  _dayOffset++;
                  print('_buildNavigation: _dayOffset incrementado a $_dayOffset');
                } else {
                  _weekOffset++;
                  print('_buildNavigation: _weekOffset incrementado a $_weekOffset');
                }
              });
              _fetchEvents();
            },
            icon: const Icon(Icons.arrow_forward, color: Color(0xFF007AFF)),
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
      return DateFormat('EEEE, d MMM').format(_currentDay); // Fallback sin locale
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
    print('_buildCalendarView: Construyendo vista de calendario (_loading: $_loading, _events: ${_events.length})');
    
    if (_loading && _events.isEmpty) {
      print('_buildCalendarView: Mostrando indicador de carga');
      return const Center(child: CircularProgressIndicator());
    }

    print('_buildCalendarView: Vista seleccionada: $_viewMode');
    return RefreshIndicator(
      onRefresh: () {
        print('_buildCalendarView: RefreshIndicator activado');
        return _fetchEvents();
      },
      color: const Color(0xFF007AFF),
      child: _viewMode == 'diaria' 
          ? _buildDailyView()
          : _buildWeeklyView(),
    );
  }

  Widget _buildDailyView() {
    print('_buildDailyView: Construyendo vista diaria con ${_filteredEvents.length} eventos');
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getFormattedDay(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007AFF),
                ),
              ),
              const SizedBox(height: 10),
              ..._filteredEvents.map(_buildEventItem).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyView() {
    print('_buildWeeklyView: Construyendo vista semanal');
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Encabezado de días
          _buildWeekHeader(),
          Expanded(
            child: ListView(
              children: [
                ..._hourSlots.map((slot) {
                  return _buildTimeSlotRow(slot);
                }).toList(),
              ],
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
        border: Border(bottom: BorderSide(color: Color(0xFFdddddd))),
      ),
      child: Row(
        children: [
          // Celda de hora
          Container(
            width: 60,
            alignment: Alignment.center,
            child: const Text(
              'Hora',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
          // Días de la semana
          ..._weekDays.map((day) {
            final isToday = day.day == DateTime.now().day &&
                           day.month == DateTime.now().month &&
                           day.year == DateTime.now().year;
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFFb3e0ff) : const Color(0xFFf0f0f0),
                  border: const Border(right: BorderSide(color: Color(0xFFdddddd))),
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
                      DateFormat('d MMM', 'es_ES').format(day),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
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
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFeeeeee))),
      ),
      child: Row(
        children: [
          // Hora
          Container(
            width: 60,
            alignment: Alignment.center,
            child: slot['minutes'] == 0
                ? Text(
                    '${slot['hour']!.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          // Celdas de días
          ..._weekDays.map((day) {
            return Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Color(0xFFeeeeee))),
                ),
                // Aquí irían los eventos para esta celda
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

 // En _buildEventItem, actualiza el formato de hora:
  Widget _buildEventItem(Event event) {
    final isPast = event.end?.dateTime?.isBefore(DateTime.now()) ?? false;
    final start = event.start?.dateTime;
    final end = event.end?.dateTime;
    
    print('_buildEventItem: Construyendo evento - ${event.summary} (pasado: $isPast)');
    
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
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
              ),
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