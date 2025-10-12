import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';
import '../../services/calendar_service.dart';

class AddEventPage extends StatefulWidget {
  final String calendarId;
  final CalendarService calendarService;
  final DateTime? initialDate;

  const AddEventPage({
    super.key,
    required this.calendarId,
    required this.calendarService,
    this.initialDate,
  });

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _endTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  bool _isAllDay = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _startDate = widget.initialDate!;
      _endDate = widget.initialDate!.add(const Duration(hours: 1));
      _startTime = TimeOfDay.fromDateTime(widget.initialDate!);
      _endTime = TimeOfDay.fromDateTime(widget.initialDate!.add(const Duration(hours: 1)));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
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
          ..timeZone = 'UTC';
        event.end = gcal.EventDateTime()
          ..date = DateTime(_endDate.year, _endDate.month, _endDate.day)
          ..timeZone = 'UTC';
      } else {
        final startDateTime = _combineDateAndTime(_startDate, _startTime);
        final endDateTime = _combineDateAndTime(_endDate, _endTime);

        event.start = gcal.EventDateTime()
          ..dateTime = startDateTime
          ..timeZone = 'Europe/Madrid'; // Ajusta según tu zona horaria
        event.end = gcal.EventDateTime()
          ..dateTime = endDateTime
          ..timeZone = 'Europe/Madrid'; // Ajusta según tu zona horaria
      }

      await widget.calendarService.addEvent(calendarId: widget.calendarId, event: event );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retornar éxito
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el evento: $e'),
            backgroundColor: Colors.red,
          ),
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

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es_ES').format(date);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Evento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _createEvent,
              tooltip: 'Guardar evento',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Título del evento
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título del evento *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
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
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Ubicación
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Todo el día
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 12),
                            const Text(
                              'Todo el día',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.access_time, size: 20),
                                SizedBox(width: 12),
                                Text(
                                  'Inicio',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _selectDate(context, true),
                                    child: Text(_formatDate(_startDate)),
                                  ),
                                ),
                                if (!_isAllDay) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _selectTime(context, true),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.timer_off, size: 20),
                                SizedBox(width: 12),
                                Text(
                                  'Fin',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _selectDate(context, false),
                                    child: Text(_formatDate(_endDate)),
                                  ),
                                ),
                                if (!_isAllDay) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _selectTime(context, false),
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
}