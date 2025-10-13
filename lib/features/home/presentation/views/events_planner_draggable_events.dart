import 'extension.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

class PlannerEventsDrag extends StatelessWidget {
  final dynamic eventsController;

  const PlannerEventsDrag({
    super.key,
    required this.daysShowed,
    required this.eventsController,
  });

  final int daysShowed;

  @override
  Widget build(BuildContext context) {
    var heightPerMinute = 1.0;
    var initialVerticalScrollOffset = heightPerMinute * 7 * 60;

    return EventsPlanner(
      controller: eventsController,
      daysShowed: daysShowed,
      heightPerMinute: heightPerMinute,
      initialVerticalScrollOffset: initialVerticalScrollOffset,
      onDayChange: (firstDay) {
        print("Día inicial: cambiado a: $firstDay");
      },
      offTimesParam: OffTimesParam(
        offTimesAllDaysRanges: [
          // Oculta horas antes de las 7:00 AM
          OffTimeRange(
            TimeOfDay(hour: 0, minute: 0),
            TimeOfDay(hour: 7, minute: 0),
          ),
          // Oculta horas después de las 21:00 (9:00 PM)
          OffTimeRange(
            TimeOfDay(hour: 21, minute: 0),
            TimeOfDay(hour: 24, minute: 0),
          ),
        ],
        offTimesColor: Theme.of(context).scaffoldBackgroundColor,
      ),

      dayParam: DayParam(
        onSlotMinutesRound: 30,
        dayEventBuilder: (event, height, width, heightPerMinute) {
          return draggableEvent(context, event, height, width);
        },
        slotSelectionParam: SlotSelectionParam(
          enableTapSlotSelection: true,
          enableLongPressSlotSelection: true,
          onSlotSelectionTap: (slot) => showSnack(
            context,
            slot.startDateTime.toString() +
                " : " +
                slot.durationInMinutes.toString(),
          ),
        ),
      ),
      daysHeaderParam: DaysHeaderParam(
        daysHeaderVisibility: daysShowed != 1,
        dayHeaderTextBuilder: (day) => DateFormat("E d").format(day),
        topLeftCellBuilder: (day) => Center(
          child: Text(
            DateFormat("MMM").format(day),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      fullDayParam: FullDayParam(fullDayEventsBarHeight: 50),
    );
  }

  DefaultDayHeader getDayHeader(
    DateTime day,
    bool isToday,
    BuildContext context,
  ) {
    return DefaultDayHeader(
      dayText: DateFormat("E d").format(day),
      isToday: isToday,
      foregroundColor: isDarkMode
          ? Theme.of(context).colorScheme.primary
          : null,
    );
  }

  DraggableEventWidget draggableEvent(
    BuildContext context,
    Event event,
    double height,
    double width,
  ) {
    return DraggableEventWidget(
      event: event,
      height: height,
      width: width,
      onDragEnd: (columnIndex, exactStart, exactEnd, roundStart, roundEnd) {
        eventsController.updateCalendarData(
          (calendarData) => calendarData.moveEvent(event, roundStart),
        );
      },
      child: DefaultDayEvent(
        height: height,
        width: width,
        title: event.title,
        description: event.description,
        color: isDarkMode ? event.color.onPastel : event.color,
        textColor: isDarkMode ? event.textColor.pastel : event.textColor,
        onTap: () => showSnack(context, "Tap = ${event.title}"),
      ),
    );
  }
}
