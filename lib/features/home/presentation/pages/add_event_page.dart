import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import '../../services/calendar_service.dart';
import '../utils.dart';

class AddEventPage extends StatefulWidget {
  final String calendarId;
  final CalendarService calendarService;
  final DateTime? initialDate;
  final EventsController eventsController;
  final Color backgrouncolor;
  final Event? existingEvent;
  final String calendarName;

  const AddEventPage({
    super.key,
    required this.calendarId,
    required this.calendarService,
    this.initialDate,
    required this.eventsController,
    required this.backgrouncolor,
    required this.existingEvent,
    required this.calendarName,
  });

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  late DateFormat _dateFormat;
  late DateFormat _timeFormat;

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _endTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1)),
  );
  bool _isAllDay = false;
  bool _isLoading = false;
  bool _isEditing = false; // Nuevo: indica si estamos editando

  @override
  void initState() {
    super.initState();

    _isEditing = widget.existingEvent != null;

    if (_isEditing) {
      // Cargar datos del evento existente
      _loadExistingEventData();
    } else if (widget.initialDate != null) {
      _startDate = widget.initialDate!;
      _endDate = widget.initialDate!.add(const Duration(hours: 1));
      _startTime = TimeOfDay.fromDateTime(widget.initialDate!);
      _endTime = TimeOfDay.fromDateTime(
        widget.initialDate!.add(const Duration(hours: 1)),
      );
    }

    _dateFormat = DateFormat('dd/MM/yyyy');
    _timeFormat = DateFormat('HH:mm');
  }

  void _loadExistingEventData() {

    if (widget.existingEvent == null) {
      print("No hay evento existente para cargar");
      return;
    }

    final event = widget.existingEvent!;

    _titleController.text = event.title ?? '';
    _descriptionController.text = event.description ?? '';

    _startDate = event.startTime;
    _endDate = event.endTime ?? event.startTime.add(const Duration(hours: 1));

    _startTime = TimeOfDay.fromDateTime(event.startTime);
    _endTime = TimeOfDay.fromDateTime(_endDate);

    _isAllDay = event.isFullDay;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final datetime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return _timeFormat.format(datetime);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = DateTime(picked.year, picked.month, picked.day);
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(hours: 1));
            _endTime = TimeOfDay.fromDateTime(_endDate);
          }
        } else {
          _endDate = DateTime(picked.year, picked.month, picked.day);
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('es', 'ES'),
          child: child,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          _startDate = DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
            _startTime.hour,
            _startTime.minute,
          );

          // Ajustar la hora de fin si es necesario
          final newStartDateTime = DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
            _startTime.hour,
            _startTime.minute,
          );
          final currentEndDateTime = DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            _endTime.hour,
            _endTime.minute,
          );

          if (newStartDateTime.isAfter(currentEndDateTime)) {
            _endTime = TimeOfDay(
              hour: (_startTime.hour + 1) % 24,
              minute: _startTime.minute,
            );
            _endDate = DateTime(
              _startDate.year,
              _startDate.month,
              _startDate.day,
              _endTime.hour,
              _endTime.minute,
            );
          }
        } else {
          _endTime = picked;
          _endDate = DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            _endTime.hour,
            _endTime.minute,
          );
        }
      });
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final event = gcal.Event()
        ..summary = _titleController.text.trim()
        ..description = _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim()
        ..location = _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim();

      if (_isAllDay) {
        event.start = gcal.EventDateTime()
          ..date = DateTime(_startDate.year, _startDate.month, _startDate.day)
          ..timeZone = 'UTC-3';
        event.end = gcal.EventDateTime()
          ..date = DateTime(_endDate.year, _endDate.month, _endDate.day)
          ..timeZone = 'UTC-3';
      } else {
        final startDateTime = _combineDateAndTime(_startDate, _startTime);
        final endDateTime = _combineDateAndTime(_endDate, _endTime);

        event.start = gcal.EventDateTime()
          ..dateTime = startDateTime
          ..timeZone = 'UTC-3';
        event.end = gcal.EventDateTime()
          ..dateTime = endDateTime
          ..timeZone = 'UTC-3';
      }

      if (_isEditing) {
        // Actualizar evento existente
        await _updateEvent(event);
      } else {
        // Crear nuevo evento
        await widget.calendarService.addEvent(
          calendarId: widget.calendarId,
          event: event,
        );
        await _addEventToCalendar(event);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Evento actualizado exitosamente'
                  : 'Evento creado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true); // Retornar éxito
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateEvent(gcal.Event updatedEvent) async {
    if (widget.existingEvent == null) {
      print("no hay evento existente para actualizar");
      return;
    }

    await widget.calendarService.updateEvent(
      calendarId: widget.calendarId,
      eventId: getGoogleEventId(widget.existingEvent!),
      updatedEvent: updatedEvent,
    );

    widget.eventsController.updateCalendarData((calendarData) {
      // Remover el evento viejo
      
      calendarData.removeEvent(widget.existingEvent!);
      _addEventToCalendar(updatedEvent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: const Text('Nuevo Evento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(
                Icons.save,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: _createEvent,
              tooltip: 'Guardar evento',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Título del evento
                    TextFormField(
                      controller: _titleController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Título del evento *',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.title,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.description,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Todo el día
                    Card(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Todo el día',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: _isAllDay,
                              onChanged: (value) {
                                setState(() {
                                  _isAllDay = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fecha y hora de inicio
                    Card(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Inicio',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _selectDate(context, true),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      side: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                    ),
                                    child: Text(_formatDate(_startDate)),
                                  ),
                                ),
                                if (!_isAllDay) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _selectTime(context, true),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        side: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                      ),
                                      child: Text(_formatTime(_startTime)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fecha y hora de fin
                    Card(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.timer_off,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Fin',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        _selectDate(context, false),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      side: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                    ),
                                    child: Text(_formatDate(_endDate)),
                                  ),
                                ),
                                if (!_isAllDay) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _selectTime(context, false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        side: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                      ),
                                      child: Text(_formatTime(_endTime)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _addEventToCalendar(gcal.Event event) async {
    _convertToCalendarEvents([event]);
  }

  void _convertToCalendarEvents(List<gcal.Event> googleEvents) {
    final calendarEvents = googleEvents.map((googleEvent) {
      DateTime startDate;
      DateTime endDate;
      if (googleEvent.start?.dateTime != null) {
        startDate = googleEvent.start!.dateTime!.toLocal();
        endDate =
            googleEvent.end?.dateTime?.toLocal() ??
            startDate.add(const Duration(hours: 1));
      } else {
        startDate = DateTime.now().toLocal();
        endDate = startDate.add(const Duration(hours: 1));
      }

      return Event(
        title: googleEvent.summary ?? 'No Title',
        description: googleEvent.description ?? '',
        startTime: startDate,
        endTime: endDate,
        color: widget.backgrouncolor ?? Colors.blue,
        isFullDay: googleEvent.start?.date != null,
        data: {
          'googleEventId': googleEvent.id,
          'createdBy': googleEvent.creator?.email ?? 'unknown',
          'calendarName': widget.calendarName,
        },
      );
    }).toList();

    widget.eventsController.updateCalendarData((calendarData) {
      calendarData.addEvents(calendarEvents);
      print(calendarData.toString());
    });
  }
}
