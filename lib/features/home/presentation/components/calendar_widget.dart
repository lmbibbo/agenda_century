import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:agenda_century/features/home/services/calendar_service.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

class CustomCalendarView extends StatefulWidget {
  final String calendarId;
  final CalendarService calendarService;
  final EventsController eventsController;
  const CustomCalendarView({
    super.key,
    required this.calendarId,
    required this.calendarService,
    required this.eventsController,
  });

  @override
  State<CustomCalendarView> createState() => _CustomCalendarViewState();
}

class _CustomCalendarViewState extends State<CustomCalendarView> {
  late EventsController _eventsController;
  final double _heightPerMinute = 1.0;
  final double _initialVerticalScrollOffset = 1.0 * 7 * 60;

  @override
  void initState() {
    super.initState();
    _eventsController = EventsController();
    _loadCalendarEvents();
  }

  Future<void> _loadCalendarEvents() async {
    try {
      final events = await widget.calendarService.getEvents(
        calendarId: widget.calendarId,
        timeMin: DateTime.now().subtract(const Duration(days: 30)).toUtc(),
        timeMax: DateTime.now().add(const Duration(days: 30)).toUtc(),
      );

      _convertToCalendarEvents(events);
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  void _convertToCalendarEvents(List<gcal.Event> googleEvents) {
    final calendarEvents = googleEvents.map((googleEvent) {
      DateTime startDate;
      DateTime endDate;
      if (googleEvent.start?.dateTime != null ) {
        startDate = googleEvent.start!.dateTime!;
        endDate = googleEvent.end?.dateTime ?? startDate.add(const Duration(hours: 1));
      } else {
        startDate = DateTime.now();
        endDate = startDate.add(const Duration(hours: 1));
      }

    return Event(
        title: googleEvent.summary ?? 'No Title',
        description: googleEvent.description ?? '',
        startTime: startDate,
        endTime: endDate,
        color: Colors.blue,
        isFullDay: googleEvent.start?.date != null
      );
    }).toList();

    _eventsController.updateCalendarData((calendarData) {
      calendarData.addEvents(calendarEvents);
    });
  }

  @override
  Widget build(BuildContext context) {
    return EventsPlanner(
      controller: _eventsController,
      daysShowed: 3, // Puedes hacer esto configurable
      heightPerMinute: _heightPerMinute,
      initialVerticalScrollOffset: _initialVerticalScrollOffset,
      dayParam: DayParam(
        slotSelectionParam: SlotSelectionParam(
          enableLongPressSlotSelection: true,
        ),
      ),
    );
  }
}