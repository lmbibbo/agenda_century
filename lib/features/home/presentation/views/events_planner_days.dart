import 'package:agenda_century/features/home/presentation/pages/add_event_page.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import '../utils.dart';

class PlannerDays extends StatefulWidget {
  final dynamic eventsController;
  final dynamic calendarService;
  final String calendarId;
  final gcal.CalendarListEntry calendar;
  final int daysShowed;

  const PlannerDays({
    super.key,
    required this.eventsController,
    required this.calendarService,
    required this.calendarId,
    required this.calendar,
    required this.daysShowed,
  });

  @override
  State<PlannerDays> createState() => _PlannerDaysState();
}

class _PlannerDaysState extends State<PlannerDays> {
  late EventHandler eventHandler;

  @override
  void initState() {
    super.initState();
    // print(  'Calendar ID en PlannerThreeDays: ${widget.calendarId}');
    eventHandler = EventHandler(
      context: context,
      eventsController: widget.eventsController,
      calendarService: widget.calendarService,
    );
  }

  @override
  Widget build(BuildContext context) {
    var heightPerMinute = 1.0;
    var initialVerticalScrollOffset = heightPerMinute * 7 * 60;

    return EventsPlanner(
      controller: widget.eventsController, // Usar widget.eventsController
      daysShowed: widget.daysShowed,
      heightPerMinute: heightPerMinute,
      initialVerticalScrollOffset: initialVerticalScrollOffset,
      offTimesParam: OffTimesParam(
        offTimesAllDaysRanges: [
          OffTimeRange(
            TimeOfDay(hour: 0, minute: 0),
            TimeOfDay(hour: 7, minute: 0),
          ),
          OffTimeRange(
            TimeOfDay(hour: 21, minute: 0),
            TimeOfDay(hour: 24, minute: 0),
          ),
        ],
        offTimesColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      daysHeaderParam: DaysHeaderParam(
        daysHeaderVisibility: true,
        dayHeaderTextBuilder: (day) => DateFormat("E d").format(day),
        daysHeaderColor: Theme.of(context).primaryColor,
      ),
      dayParam: DayParam(
        dayEventBuilder: (event, height, width, heightPerMinute) {
          return DefaultDayEvent(
            height: height,
            width: width,
            title: horasEvento(event),
            description: event.description,
            color: event.color,
            textColor: event.textColor,
            roundBorderRadius: 15,
            horizontalPadding: 8,
            verticalPadding: 4,
            onTap: () => eventHandler.showEventModal(event, widget.calendarId),
            onTapDown: (details) =>
                print("tapdown ${event.uniqueId} details ${details}"),
          );
        },
        slotSelectionParam: SlotSelectionParam(
          enableTapSlotSelection: true,
          enableLongPressSlotSelection: true,
          onSlotSelectionTap: (slot) => _showAddEventDialog(
            context,
            slot.startDateTime,
            slot.durationInMinutes,
          ),
        ),
      ),
    );
  }

  void _showAddEventDialog(
    BuildContext context,
    DateTime startDateTime,
    int durationInMinutes,
  ) async {
    print("Mostrando diálogo para agregar evento");
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEventPage(
          calendarId: widget.calendarId,
          calendarService: widget.calendarService,
          eventsController: widget.eventsController,
          backgrouncolor: parseColor(widget.calendar!.backgroundColor!),
          initialDate:startDateTime, //DateTime.now(), // O la fecha seleccionada en el calendario
          initialTime: TimeOfDay.fromDateTime(startDateTime),
          finalTime: TimeOfDay.fromDateTime(
            (startDateTime).add(Duration(minutes: durationInMinutes)),
          ),
          existingEvent: null, // Indica que es un nuevo evento
          calendarName: widget.calendar?.summary ?? 'Calendario',
        ),
      ),
    );

    if (result == true) {
      // Recargar eventos si se creó uno nuevo
      //widget.eventsController.updateCalendarData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Evento agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
