import 'widgets/calendar.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';
import '../utils.dart';

class PlannerOneDay extends StatefulWidget {
  final dynamic eventsController;
  final dynamic calendarService;
  final String calendarId;

  const PlannerOneDay({super.key, required this.eventsController, required this.calendarService, required this.calendarId });

  @override
  State<PlannerOneDay> createState() => _PlannerOneDayState();
}

class _PlannerOneDayState extends State<PlannerOneDay> with RouteAware {
  GlobalKey<EventsPlannerState> oneDayViewKey = GlobalKey<EventsPlannerState>();
  late DateTime selectedDay;
  late EventHandler eventHandler;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedDay = widget.eventsController.focusedDay;
    print('Calendar ID en PlannerOneDay: ${widget.calendarId}');
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

    return Column(
      children: [
        const SizedBox(height: 8.0),
        buildCalendar(),
        const SizedBox(height: 4.0),
        Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 2),
        Expanded(
          child: EventsPlanner(
            key: oneDayViewKey,
            controller: widget.eventsController,
            daysShowed: 1,
            heightPerMinute: heightPerMinute,
            initialVerticalScrollOffset: initialVerticalScrollOffset,
            horizontalScrollPhysics: const PageScrollPhysics(),
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
              daysHeaderVisibility: false,
              dayHeaderTextBuilder: (day) => DateFormat("E d").format(day),
            ),
            onDayChange: (firstDay) {
              print("Día cambiado a: $firstDay");
              setState(() {
                selectedDay = firstDay;
              });
            },
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
                  onTapDown: (details) => print("tapdown ${event.uniqueId}"),
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
          ),
        ),
      ],
    );
  }

  Calendar buildCalendar() {
    return Calendar(
      selectedDay: selectedDay,
      headerVisible: false,
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        print("Día seleccionado: $selectedDay y FocusedDay: $focusedDay");
        setState(() {
          this.selectedDay = selectedDay;
        });
        widget.eventsController.updateFocusedDay(selectedDay);
        oneDayViewKey.currentState?.jumpToDate(selectedDay);
      },
    );
  }
}
