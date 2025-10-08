import 'package:flutter/material.dart';
import 'package:agenda_century/features/home/presentation/components/calendar_widget.dart';
import 'package:agenda_century/features/home/services/calendar_service.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

class ShowCalendarPage extends StatelessWidget {
  final String calendarId;
  final CalendarListEntry? calendar;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(calendar?.summary ?? 'Calendario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: togglePages,
        ),
        actions: [
          // Puedes añadir aquí botones para cambiar la vista
          IconButton(
            icon: const Icon(Icons.view_week),
            onPressed: () {
              // Cambiar entre vistas (día, 3 días, semana, etc.)
            },
          ),
        ],
      ),
      body: CustomCalendarView(
        calendarId: calendarId,
        calendarService: calendarService,
        eventsController: eventsController,
      ),
    );
  }
}