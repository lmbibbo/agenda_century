import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';

// Componente personalizado para cada item del calendario
class CalendarListItem extends StatelessWidget {
  final CalendarListEntry calendar;
  final VoidCallback? onTap;

  const CalendarListItem({
    super.key,
    required this.calendar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2c3e50),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del calendario
            Text(
              calendar.summary ?? 'No Title',
              style: const TextStyle(
                color: Color.fromARGB(255, 255,255,255),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            // ID del calendario
            Text(
              calendar.id ?? 'No ID',
              style: const TextStyle(
                color: Color(0xFFbdc3c7),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}