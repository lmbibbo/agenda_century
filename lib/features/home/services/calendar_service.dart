import 'package:googleapis/calendar/v3.dart';
import 'package:http/http.dart' as http;

class CalendarService {
  final String _userAccessToken; // Token del Usuario (usuario de prueba)
  //final String _userAEmail; // Email del Usuario A (dueño de la API)
  //final String _userACalendarId; // ID específico del calendario de A
  late final CalendarApi _calendarApi;

  CalendarService({required String userAccessToken})
    : _userAccessToken = userAccessToken {
    _calendarApi = _initializeCalendarApi();
  }

  // ✅ INICIALIZAR API CON TOKEN DE USUARIO B (usuario de prueba)
  CalendarApi _initializeCalendarApi() {
    final client = AuthenticatedClient(_userAccessToken);
    return CalendarApi(client);
  }

  // 📅 OBTENER CALENDARIOS A LOS QUE TIENE ACCESO USUARIO B
  // Como usuario de prueba de la API de Usuario A
  Future<List<CalendarListEntry>> getAvailableCalendars() async {
    try {
      // print('🔍 Obteniendo calendarios disponibles para usuario de prueba...');

      final calendarList = await _calendarApi.calendarList.list();
      final calendars = calendarList.items ?? [];

      // print('✅ ${calendars.length} calendarios disponibles');

      // Mostrar información de cada calendario
      for (final calendar in calendars) {
        // print('📅 ${calendar.summary} (${calendar.id}) - ${calendar.accessRole}');
      }

      return calendars;
    } catch (error) {
      // print('❌ Error obteniendo calendarios: $error');
      rethrow;
    }
  }

  // 🗓️ OBTENER EVENTOS DE UN CALENDARIO ESPECÍFICO
  Future<List<Event>> getEvents({
    required String calendarId,
    required DateTime timeMin,
    required DateTime timeMax,
    int maxResults = 100,
    bool singleEvents = true,
    String orderBy = 'startTime',
  }) async {
    try {
      // print('📅 Obteniendo eventos del calendario $calendarId...');
      // print('📅 Rango: $timeMin a $timeMax');

      final events = await _calendarApi.events.list(
        calendarId,
        timeMin: timeMin,
        timeMax: timeMax,
        maxResults: maxResults,
        singleEvents: singleEvents,
        orderBy: orderBy,
      );

      final eventList = events.items ?? [];

      // print('✅ ${eventList.length} eventos encontrados en el calendario');
      for (final event in eventList) {
        final start = event.start?.dateTime ?? event.start?.date;
        // print('  - ${event.summary} ($start)');
      }

      return eventList;
    } catch (error) {
      // print('❌ Error obteniendo eventos: $error');
      rethrow;
    }
  }

  // ➕ AGREGAR EVENTO A UN CALENDARIO
  Future<Event> addEvent({
    required String calendarId,
    required Event event,
  }) async {
    try {
      // print('➕ Agregando evento al calendario $calendarId...');

      final createdEvent = await _calendarApi.events.insert(event, calendarId);
      // print('✅ Evento agregado exitosamente: ${createdEvent.id}');
      return createdEvent;
    } catch (error) {
      // print('❌ Error agregando evento: $error');
      rethrow;
    }
  }

  // 🗑️ ELIMINAR EVENTO
  Future<void> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    try {
      // print('🗑️ Eliminando evento $eventId del calendario $calendarId...');

      await _calendarApi.events.delete(calendarId, eventId);

      // print('✅ Evento eliminado exitosamente');
    } catch (error) {
      // print('❌ Error eliminando evento: $error');
      rethrow;
    }
  }

  // 🔍 BUSCAR EVENTOS
  Future<List<Event>> searchEvents({
    required String calendarId,
    required String query,
    int maxResults = 20,
    DateTime? timeMin,
    DateTime? timeMax,
  }) async {
    try {
      // print('🔍 Buscando "$query" en calendario $calendarId...');

      final events = await _calendarApi.events.list(
        calendarId,
        q: query,
        maxResults: maxResults,
        timeMin: timeMin,
        timeMax: timeMax,
        singleEvents: true,
        orderBy: 'startTime',
      );

      final eventList = events.items ?? [];

      // print('✅ ${eventList.length} eventos encontrados con "$query"');
      return eventList;
    } catch (error) {
      // print('❌ Error buscando eventos: $error');
      rethrow;
    }
  }

  // En calendar_service.dart - agregar después del método addEvent

  // ✏️ ACTUALIZAR EVENTO EXISTENTE
  Future<Event> updateEvent({
    required String calendarId,
    required String eventId,
    required Event updatedEvent,
  }) async {
    try {
      final Event existingEvent = await getEvent(
        calendarId: calendarId,
        eventId: eventId,
      );

      if (existingEvent == null) {
        throw Exception(
          'El evento con ID $eventId no existe en el calendario $calendarId.',
        );
      }
      // print('✏️ Actualizando evento $eventId en calendario $calendarId...');
      // print('📅 CalendarId: $calendarId');
      // print('🎯 EventId: $eventId');
      // print('📝 Event summary: ${updatedEvent.summary}');
      // print('🕐 Event start: ${updatedEvent.start?.dateTime ?? updatedEvent.start?.date}');
      // print('🕐 Event end: ${updatedEvent.end?.dateTime ?? updatedEvent.end?.date}');

      // Preservar el eventId en el evento actualizado
      updatedEvent.id = eventId;

      final result = await _calendarApi.events.update(
        updatedEvent,
        calendarId,
        eventId,
      );

      // print('✅ Evento actualizado exitosamente: ${result.id}');
      return result;
    } catch (error) {
      // print('❌ Error actualizando evento: $error');
      // print('🔍 Error details:');
      // print('  - CalendarId: $calendarId');
      // print('  - EventId: $eventId');
      // print('  - Event exists: ${updatedEvent.summary != null}');
      rethrow;
    }
  }

  // 🔍 OBTENER EVENTO POR ID (útil para update)
  Future<Event> getEvent({
    required String calendarId,
    required String eventId,
  }) async {
    try {
      // print('🔍 Obteniendo evento $eventId del calendario $calendarId...');

      final event = await _calendarApi.events.get(calendarId, eventId);

      // print('✅ Evento obtenido: ${event.summary}');
      return event;
    } catch (error) {
      // print('❌ Error obteniendo evento: $error');
      rethrow;
    }
  }
}

// ✅ CLIENTE HTTP AUTENTICADO
class AuthenticatedClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  AuthenticatedClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    return _client.send(request);
  }
}
