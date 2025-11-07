import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

class CalendarListItem extends StatelessWidget {
  final gcal.CalendarListEntry calendar;
  final VoidCallback onTap;

  const CalendarListItem({
    super.key,
    required this.calendar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información principal
              _buildMainInfo(context),
              const SizedBox(height: 12),
              
              // Información de acceso y propiedades
              //_buildAccessInfo(context),
              
              // Metadata técnica
              //_buildTechnicalInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color del calendario
        if (calendar.backgroundColor != null) ...[
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _parseColor(calendar.backgroundColor!),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        
        // Información principal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                calendar.summary ?? 'Sin nombre',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              /*if (calendar.description != null && calendar.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  calendar.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],*/
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccessInfo(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (calendar.accessRole != null)
          _buildInfoChip(
            context: context,
            label: 'Rol',
            value: _translateAccessRole(calendar.accessRole!),
            icon: Icons.security,
          ),
        
        if (calendar.primary == true)
          _buildInfoChip(
            context: context,
            label: 'Principal',
            value: 'Sí',
            icon: Icons.star,
            isPrimary: true,
          ),
        
        if (calendar.selected != null)
          _buildInfoChip(
            context: context,
            label: 'Seleccionado',
            value: calendar.selected! ? 'Sí' : 'No',
            icon: Icons.check_circle,
          ),
        
        if (calendar.colorId != null)
          _buildInfoChip(
            context: context,
            label: 'Color ID',
            value: calendar.colorId!,
            icon: Icons.palette,
          ),
      ],
    );
  }

  Widget _buildTechnicalInfo(BuildContext context) {
    final technicalItems = <Widget>[];

    if (calendar.id != null) {
      technicalItems.add(_buildTechInfoRow(context, 'ID:', calendar.id!));
    }
    
    if (calendar.kind != null) {
      technicalItems.add(_buildTechInfoRow(context, 'Kind:', calendar.kind!));
    }
    
    if (calendar.etag != null) {
      technicalItems.add(_buildTechInfoRow(context, 'ETag:', _shortenEtag(calendar.etag!)));
    }
    
    if (calendar.foregroundColor != null) {
      technicalItems.add(_buildTechInfoRow(context, 'Color texto:', calendar.foregroundColor!));
    }

    if (technicalItems.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Información técnica:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          ...technicalItems,
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildInfoChip({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary 
            ? Colors.amber.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary 
              ? Colors.amber.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isPrimary ? Colors.amber : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isPrimary ? Colors.amber : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares
  Color _parseColor(String colorHex) {
    try {
      final hexCode = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  String _translateAccessRole(String accessRole) {
    switch (accessRole) {
      case 'owner':
        return 'Propietario';
      case 'writer':
        return 'Editor';
      case 'reader':
        return 'Lector';
      case 'freeBusyReader':
        return 'Lector Ocupado';
      default:
        return accessRole;
    }
  }

  String _shortenEtag(String etag) {
    if (etag.length > 20) {
      return '${etag.substring(0, 10)}...';
    }
    return etag;
  }
}