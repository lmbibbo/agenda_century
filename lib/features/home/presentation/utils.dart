import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';
import '../presentation/views/widgets/event_view.dart';

var isDarkMode = false;

showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.surface),
      ),
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      duration: Duration(seconds: 1),
      showCloseIcon: true,
      closeIconColor: Theme.of(context).colorScheme.surface,
    ),
  );
}

String getSlotHourText(DateTime start, DateTime end) {
  var startDate = "${start.hour.toTimeText()}:${start.minute.toTimeText()}";
  var endDate = "${end.hour.toTimeText()}:${end.minute.toTimeText()}";
  return "${startDate}\n${endDate}";
}

String horasEvento(Event event) {
  if (event.startTime != null && event.endTime != null) {
    String horasStr =
        event.title! +
        ": " +
        DateFormat("HH:mm").format(event.startTime!) +
        " - " +
        DateFormat("HH:mm").format(event.endTime!);
    return horasStr;
  }
  return event.title!;
}

// Método para mostrar el modal del evento
  void showEventModal(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => EventModal(
        event: event,
        calendarName: _getCalendarName(event), // Puedes personalizar esto
        createdBy: _getCreatedBy(event), // Puedes personalizar esto
        onEdit: () {
          Navigator.of(context).pop();
          _editEvent(event);
        },
        onDelete: () {
          Navigator.of(context).pop();
          _deleteEvent(event);
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // Métodos auxiliares para obtener información del calendario y creador
  String _getCalendarName(Event event) {
    // Aquí puedes personalizar cómo obtener el nombre del calendario
    // Por ejemplo, basado en el eventType o algún otro criterio
    if (event.eventType is String && event.eventType != defaultType) {
      return event.eventType.toString();
    }
    return 'Calendario Principal';
  }

  String _getCreatedBy(Event event) {
    // Aquí puedes personalizar cómo obtener el creador
    // Podrías tener esta información en el campo 'data' o en otro lugar
    if (event.data is Map && (event.data as Map).containsKey('createdBy')) {
      return (event.data as Map)['createdBy'];
    }
    return 'salascentury70@gmail.com'; // Valor por defecto
  }

  // Métodos para las acciones de editar y eliminar
  void _editEvent(Event event) {
    // Implementa la lógica para editar el evento
    print('Editar evento: ${event.uniqueId}');
  }

  void _deleteEvent(Event event) {
    // Implementa la lógica para eliminar el evento
    print('Eliminar evento: ${event.uniqueId}');
   
    // Ejemplo de cómo eliminar el evento del controlador
    // widget.eventsController.removeEvent(event);
  }