import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';
import '../utils.dart';

class PlannerTreeDays extends StatelessWidget {
  final dynamic eventsController;

  const PlannerTreeDays({super.key, required this.eventsController});

  @override
  Widget build(BuildContext context) {
    var heightPerMinute = 1.0;
    var initialVerticalScrollOffset = heightPerMinute * 7 * 60;

    return EventsPlanner(
      controller: eventsController,
      daysShowed: 3,
      heightPerMinute: heightPerMinute,
      initialVerticalScrollOffset: initialVerticalScrollOffset,
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

      daysHeaderParam: DaysHeaderParam(
        daysHeaderVisibility: true,
        dayHeaderTextBuilder: (day) => DateFormat("E d").format(day),
        daysHeaderColor: Theme.of(context).primaryColor,
      ),

      dayParam: DayParam(
        // onSlotMinutesRound: 60,
        // onSlotRoundAlwaysBefore: true,
        dayEventBuilder: (event, height, width, heightPerMinute) {
          return DefaultDayEvent(
            height: height,
            width: width,
            title: _horasEvento(event),
            description: event.description,
            color: event.color,
            textColor: event.textColor,
            roundBorderRadius: 15,
            horizontalPadding: 8,
            verticalPadding: 4,
            onTap: () => print("tap ${event.uniqueId}"),
            onTapDown: (details) => print("tapdown ${event.uniqueId}"),
          );
        },

        slotSelectionParam: SlotSelectionParam(
          enableTapSlotSelection: true,
          enableLongPressSlotSelection: true,
          onSlotSelectionTap: (slot) => showSnack(
            context,
            "${slot.startDateTime} : ${slot.durationInMinutes}",
          ),
        ),
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
