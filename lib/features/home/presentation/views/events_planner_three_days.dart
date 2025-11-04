import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';
import '../utils.dart';

class PlannerTreeDays extends StatefulWidget {
  final dynamic eventsController;
  final dynamic calendarService; 
  final String calendarId;

  const PlannerTreeDays({
    super.key, 
    required this.eventsController,
    required this.calendarService, 
    required this.calendarId
  });

  @override
  State<PlannerTreeDays> createState() => _PlannerTreeDaysState();
}

class _PlannerTreeDaysState extends State<PlannerTreeDays> {
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
      daysShowed: 3,
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
            onTapDown: (details) => print("tapdown ${event.uniqueId} details ${details}"),
          );
        },
        slotSelectionParam: SlotSelectionParam(
          enableTapSlotSelection: true,
          enableLongPressSlotSelection: true,
          onSlotSelectionTap: (slot) => showSnack(
            context,
            "Hola ${slot.startDateTime} : ${slot.durationInMinutes}",
          ),
        ),
      ),
    );
  }
}