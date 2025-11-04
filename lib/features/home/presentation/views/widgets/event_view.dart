import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

class EventModal extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onClose;
  final String calendarName; // Nuevo parámetro para el nombre del calendario
  final String createdBy; // Nuevo parámetro para el creador
  final BuildContext parentContext; // Nuevo: contexto para navegación

  const EventModal({
    Key? key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required this.onClose,
    this.calendarName = 'Calendario Principal', // Valor por defecto
    this.createdBy = 'salascentury70@gmail.com', // Valor por defecto
    required this.parentContext,
  }) : super(key: key);

  // Método estático para mostrar el modal fácilmente
  static void show({
    required BuildContext context,
    required Event event,
    required String calendarName,
    required String createdBy,
    required Function(Event) onEdit,
    required Function(Event) onDelete,
  }) {
    showDialog(
      context: context,
      builder: (context) => EventModal(
        event: event,
        parentContext: context, // Guardar el contexto original
        calendarName: calendarName,
        createdBy: createdBy,
        onEdit: () => onEdit(event),
        onDelete: () => onDelete(event),
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con íconos de acciones
            _buildHeader(),
            const SizedBox(height: 16),

            // Información del evento
            _buildEventInfo(),

            // Descripción si existe
            if (event.description != null && event.description!.isNotEmpty)
              _buildDescription(),

            // Información del calendario
            _buildCalendarInfo(),

            // Información del creador
            _buildCreatorInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Color y título
        Expanded(
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: event.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.title ?? 'Sin título',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Íconos de acciones
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              tooltip: 'Editar evento',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: onDelete,
              tooltip: 'Eliminar evento',
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onClose,
              tooltip: 'Cerrar',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(icon: Icons.access_time, text: _formatEventDate()),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.calendar_view_day,
          text: event.isFullDay
              ? 'Evento de día completo'
              : 'Evento con horario',
        ),
        if (event.isMultiDay) ...[
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.view_week,
            text: 'Evento de múltiples días',
          ),
        ],
        if (event.eventType != defaultType) ...[
          const SizedBox(height: 8),
          _buildInfoRow(icon: Icons.category, text: 'Tipo: ${event.eventType}'),
        ],
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: _buildInfoRow(icon: Icons.description, text: event.description!),
    );
  }

  Widget _buildCalendarInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: _buildInfoRow(icon: Icons.calendar_today, text: calendarName),
    );
  }

  Widget _buildCreatorInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        'Creado por: $createdBy',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  String _formatEventDate() {
    try {
      final dateFormat = DateFormat('EEEE, d MMMM', 'es_ES');
      final timeFormat = DateFormat('HH:mm');

      final startDate = event.startTime;

      if (event.isFullDay) {
        final formattedDate = dateFormat.format(startDate);
        return '$formattedDate: Todo el día';
      }

      final formattedDate = dateFormat.format(startDate);
      final startTime = timeFormat.format(startDate);

      if (event.endTime != null) {
        final endTime = timeFormat.format(event.endTime!);
        return '$formattedDate: $startTime - $endTime';
      } else {
        return '$formattedDate: $startTime';
      }
    } catch (e) {
      return 'Error al formatear fecha';
    }
  }
}
