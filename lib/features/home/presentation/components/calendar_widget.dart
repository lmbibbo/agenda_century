import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:agenda_century/features/home/services/calendar_service.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import '../enumerations.dart';
import '../views/events_list.dart';
import '../views/events_planner_one_day.dart';
import '../views/events_planner_draggable_events.dart';
import '../views/events_planner_three_days.dart';
import '../views/events_months.dart';

class CustomCalendarView extends StatefulWidget {
  final String calendarId;
  final CalendarService calendarService;
  final EventsController eventsController;
  final Mode calendarMode;
  final Color? backgrouncolor;

  const CustomCalendarView({
    super.key,
    required this.calendarId,
    required this.calendarService,
    required this.eventsController,
    required this.calendarMode,
    this.backgrouncolor
  });

  @override
  State<CustomCalendarView> createState() => _CustomCalendarViewState();
}

class _CustomCalendarViewState extends State<CustomCalendarView> {
  final double _heightPerMinute = 1.0;
  final double _initialVerticalScrollOffset = 1.0 * 7 * 60;


  @override
  void initState() {
    super.initState();
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
        startDate = googleEvent.start!.dateTime!.toLocal();
        endDate = googleEvent.end?.dateTime?.toLocal() ?? startDate.add(const Duration(hours: 1));
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
        isFullDay: googleEvent.start?.date != null
      );
    }).toList();

    widget.eventsController.calendarData.clearAll();
    widget.eventsController.updateCalendarData((calendarData) {
      calendarData.addEvents(calendarEvents);
    });
  }

  @override
  Widget build(BuildContext context) {

    return switch (widget.calendarMode) {
      Mode.agenda => EventsListView(eventsController: widget.eventsController),
      Mode.day => PlannerOneDay(eventsController: widget.eventsController),
      Mode.day7 => PlannerEventsDrag(eventsController: widget.eventsController, key: UniqueKey(), daysShowed: 7),
      Mode.day3Draggable => PlannerTreeDays(eventsController: widget.eventsController),

      /*// TODO: Handle this case.
      Mode.month => throw UnimplementedError(),
      // TODO: Handle this case.
      Mode.multiColumn => throw UnimplementedError(),
      // TODO: Handle this case.
      Mode.multiColumn2 => throw UnimplementedError(),
      // TODO: Handle this case.
      // TODO: Handle this case.
      Mode.day3RTL => throw UnimplementedError(),
      // TODO: Handle this case.
      Mode.monthRTL => throw UnimplementedError(),
      // TODO: Handle this case.
      Mode.day3Rotation => throw UnimplementedError(),
      // TODO: Handle this case.
      Mode.day3RotationMultiColumn => throw UnimplementedError(),
      // TODO: Handle this case.
      Mode.day3 => throw UnimplementedError(),*/
      // TODO: Handle this case.
      Mode.month => Months(eventsController: widget.eventsController),
    };
  }
}