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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Verificar si el estado es Authenticated y obtener el usuario
        if (state is Authenticated) {
          //final user = state.user;
          return Scaffold(
           backgroundColor: const Color(0xFF25292e),
            body: Column(
              children: [
                // Header personalizado
                _buildHeader(context),
                // Lista de calendarios
                _buildCalendarList(),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text(
              'Usuario no autenticado',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
            color: const Color(0xFF34495e),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título centrado
          const Expanded(
            child: Text(
              'Tus Calendarios',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Botón de cerrar sesión
          GestureDetector(
            onTap: () {
              final authCubit = context.read<AuthCubit>();
              authCubit.logout();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCalendarList() {
    if (widget.calendars.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No hay calendarios',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: widget.calendars.length,
        itemBuilder: (context, index) {
          final calendar = widget.calendars[index];
          return CalendarListItem(
            calendar: calendar,
            onTap: () => widget.onSelectCalendar?.call(calendar),
          );
        },
      ),
    );
  }
}
