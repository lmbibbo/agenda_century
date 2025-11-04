import 'package:agenda_century/features/home/presentation/pages/add_event_page.dart';
import 'package:agenda_century/features/home/services/calendar_service.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';
import '../presentation/views/widgets/event_view.dart';

var isDarkMode = false;
// En el State class

class EventHandler {
  final BuildContext context;
  final CalendarService calendarService;
  final EventsController eventsController;

  EventHandler({
    required this.context,
    required this.eventsController,
    required this.calendarService,
  });

  void showEventModal(Event event, String calendarId) {
    EventModalHandler.showEventModal(
      context: context,
      event: event,
      calendarName: getCalendarName(event),
      createdBy: getCreatedBy(event),
      onEditCallback: (event) => navigateToEditPage(
        event,
        calendarService,
        eventsController,
        calendarId,
      ),
      onDeleteCallback: (event) => showDeleteDialog(event, calendarId),
    );
  }

  void navigateToEditPage(
    Event event,
    CalendarService calendarService,
    EventsController eventsController,
    String calendarId,
  ) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddEventPage(
              calendarId: calendarId,
              calendarService: calendarService,
              eventsController: eventsController,
              backgrouncolor: event.color,
              existingEvent: event,
              calendarName: getCalendarName(event),
            ),
          ),
        )
        .then((result) {
          if (result == true) {
            // print('Evento actualizado, mostrando snack');
            showSnack(context, "Evento actualizado correctamente");
            // Si necesitas refresh, usa un callback o notifier
          }
        });
  }

  void showDeleteDialog(Event event, String calendarId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Evento'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este evento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _confirmDelete(event, calendarId);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Event event, String calendarId) {

    final String eventId = getGoogleEventId(event);
    calendarService.deleteEvent(calendarId: calendarId, eventId: eventId);
    eventsController.updateCalendarData((calendarData) {
      calendarData.removeEvent(event);
    });
    showSnack(context, "Evento eliminado");
  }

  String getCalendarName(Event event) {
    if (event.data is Map && (event.data as Map).containsKey('calendarName')) {
      return (event.data as Map)['calendarName'];
    }
    return 'Calendario Principal';
  }

  String getCreatedBy(Event event) {
    if (event.data is Map && (event.data as Map).containsKey('createdBy')) {
      return (event.data as Map)['createdBy'];
    }
    return 'salascentury70@gmail.com';
  }
}

class EventModalHandler {
  static void showEventModal({
    required BuildContext context,
    required Event event,
    required String calendarName,
    required String createdBy,
    required Function(Event) onEditCallback,
    required Function(Event) onDeleteCallback,
  }) {
    showDialog(
      context: context,
      builder: (context) => EventModal(
        event: event,
        parentContext: context,
        calendarName: calendarName,
        createdBy: createdBy,
        onEdit: () {
          Navigator.of(context).pop(); // Cerrar modal
          onEditCallback(event);
        },
        onDelete: () {
          Navigator.of(context).pop(); // Cerrar modal
          onDeleteCallback(event);
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}

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

// 🆕 MÉTODOS AUXILIARES PARA UPDATE

String getGoogleEventId(Event localEvent) {
  // print('🔍 ANALIZANDO EVENTO PARA GOOGLE EVENT ID:');
  // print('  - Título: "${localEvent.title}"');
  // print('  - Tipo: ${localEvent.eventType}');
  // print('  - UniqueId: ${localEvent.uniqueId}');
  // print('  - Data type: ${localEvent.data.runtimeType}');
  // print('  - Data: ${localEvent.data}');

  // Verificar si es un evento de Google Calendar
  if (localEvent.data is Map) {
    final data = localEvent.data as Map;
    final googleEventId = data['googleEventId']?.toString();

    if (googleEventId != null && googleEventId.isNotEmpty) {
      // print('  - ✅ GoogleEventId encontrado: $googleEventId');
      return googleEventId;
    } else {
      // print('  - ❌ googleEventId es nulo o vacío');
      // print('  - Keys disponibles: ${data.keys.toList()}');
      // print('  - Valores: ${data.values.toList()}');
    }
  } else {
    // print('  - ⚠️  Data no es un Map, es: ${localEvent.data.runtimeType}');
    // print('  - Valor completo: ${localEvent.data}');
  }

  // Si llegamos aquí, el evento no tiene googleEventId
  // print('  - 🚨 ESTE EVENTO NO ES DE GOOGLE CALENDAR O NO TIENE ID');
  return '';
}
