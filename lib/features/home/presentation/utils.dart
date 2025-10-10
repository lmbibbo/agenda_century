import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

var isDarkMode = false;

showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.surface),
      ),
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      duration: Duration(seconds: 1),
      showCloseIcon: true,
      closeIconColor: Theme.of(context).colorScheme.surface,
    ),
  );
}

String getSlotHourText(DateTime start, DateTime end) {
  var startDate = "${start.hour.toTimeText()}:${start.minute.toTimeText()}";
  var endDate = "${end.hour.toTimeText()}:${end.minute.toTimeText()}";
  return "${startDate}\n${endDate}";
}
