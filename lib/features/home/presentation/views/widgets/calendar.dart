import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime selectedDay;
  final OnDaySelected onDaySelected;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: selectedDay.subtract(Duration(days: 365)),
      lastDay: selectedDay.add(Duration(days: 365)),
      focusedDay: selectedDay,
      calendarFormat: CalendarFormat.week,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      headerVisible: false,
      weekNumbersVisible: true,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        markerSize: 7,
        todayDecoration: BoxDecoration(
          color: Colors.blueGrey,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
