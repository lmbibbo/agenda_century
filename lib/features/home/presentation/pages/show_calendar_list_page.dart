import 'package:agenda_century/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:agenda_century/features/auth/presentation/cubits/auth_states.dart';
import 'package:agenda_century/features/home/presentation/components/calendar_list_item_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/calendar/v3.dart';

class ShowCalendarListPage extends StatefulWidget {
  final void Function()? togglePages;
  final List<CalendarListEntry> calendars;
  final void Function(CalendarListEntry) onSelectCalendar;

  const ShowCalendarListPage({
    super.key,
    this.togglePages,
    required this.calendars,
    required this.onSelectCalendar,
  });

  @override
  State<ShowCalendarListPage> createState() => _ShowCalendarListPageState();
}

class _ShowCalendarListPageState extends State<ShowCalendarListPage> {
  // Separar calendarios en dos listas
  List<CalendarListEntry> get _salasCenturyCalendars {
    return widget.calendars.where((calendar) {
      return calendar.id?.contains('salascentury70@gmail.com') == true ||
             calendar.summary?.toLowerCase().contains('salas') == true ||
             calendar.description?.toLowerCase().contains('salascentury') == true;
    }).toList();
  }

  List<CalendarListEntry> get _otherCalendars {
    return widget.calendars.where((calendar) {
      return !_salasCenturyCalendars.contains(calendar);
    }).toList();
  }

  bool get _hasSalasCenturyCalendars => _salasCenturyCalendars.isNotEmpty;
  bool get _hasOtherCalendars => _otherCalendars.isNotEmpty;
  bool get _hasAnyCalendars => _hasSalasCenturyCalendars || _hasOtherCalendars;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Column(
              children: [
                _buildHeader(context),
                _buildCalendarLists(),
              ],
            ),
          );
        } else {
          return Center(
            child: Text(
              'Usuario no autenticado',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          );
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Tus Calendarios',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              final authCubit = context.read<AuthCubit>();
              authCubit.logout();
            },
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarLists() {
    if (!_hasAnyCalendars) {
      return Expanded(
        child: Center(
          child: Text(
            'Sin calendarios para mostrar',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Sección de Calendarios Salas Century
            if (_hasSalasCenturyCalendars) ...[
              _buildSectionHeader(
                title: 'Salas Century',
                icon: Icons.meeting_room,
              ),
              const SizedBox(height: 16),
              _buildCalendarList(_salasCenturyCalendars),
              const SizedBox(height: 24),
            ],
            
            // Sección de Otros Calendarios
            if (_hasOtherCalendars) ...[
              _buildSectionHeader(
                title: 'Mis Calendarios',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 16),
              _buildCalendarList(_otherCalendars),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarList(List<CalendarListEntry> calendars) {

    final sortedCalendars = List<CalendarListEntry>.from(calendars)
    ..sort((a,b) => (a.summary ?? '').compareTo(b.summary ?? ''));
    
    return Column(
      children: sortedCalendars.map((calendar) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CalendarListItem(
            calendar: calendar,
            onTap: () => widget.onSelectCalendar.call(calendar),
          ),
        );
      }).toList(),
    );
  }
}