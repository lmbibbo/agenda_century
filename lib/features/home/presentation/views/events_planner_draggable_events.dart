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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        dayHeaderBuilder: (day, isToday) {
          return Container(
            decoration: BoxDecoration(
              color: isToday
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*Text(
                  DateFormat("E").format(day), // Día de la semana (Lun, Mar, etc.)
                  style: TextStyle(
                    fontSize: 12,
                    color: isToday 
                        ? Theme.of(context).colorScheme.onPrimary 
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),*/
                SizedBox(height: 2),
                Container(
                  //width: 32,
                  //height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    border: isToday
                        ? null
                        : Border.all(color: Colors.transparent, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat("d").format(day), // Día del mes
                      style: TextStyle(
                        fontSize: 16,
                        color: isToday
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      fullDayParam: FullDayParam(fullDayEventsBarHeight: 50),
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
        title: _horasEvento(event),
        description: event.description,
        color: isDarkMode ? event.color.onPastel : event.color,
        textColor: isDarkMode ? event.textColor.pastel : event.textColor,
        onTap: () => showSnack(context, "Tap = ${event.title}"),
      ),
    );
  }

  String _horasEvento(Event event) {
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
}
