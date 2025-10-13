import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

class Months extends StatelessWidget {
  final EventsController eventsController;
  const Months({super.key, required this.eventsController});

  @override
  Widget build(BuildContext context) {
    return EventsMonths(
      controller: eventsController,
      onMonthChange: (monthFirstDay) {
        print("Día inicial del mes: $monthFirstDay");
      },
      daysParam: DaysParam(
        // custom builder : add drag and drop
        dayEventBuilder: (event, width, height) {
          return DraggableMonthEvent(
            child: DefaultMonthDayEvent(event: event),
            onDragEnd: (DateTime day) {
              eventsController.updateCalendarData(
                (data) => move(data, event, day),
              );
            },
          );
        },
      ),
    );
  }

  move(CalendarData data, Event event, DateTime newDay) {
    data.moveEvent(
      event,
      newDay.copyWith(
        hour: event.effectiveStartTime!.hour,
        minute: event.effectiveStartTime!.minute,
      ),
    );
  }
}
