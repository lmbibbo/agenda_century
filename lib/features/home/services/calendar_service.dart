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
      print('🔍 Obteniendo calendarios disponibles para usuario de prueba...');

      final calendarList = await _calendarApi.calendarList.list();
      final calendars = calendarList.items ?? [];

      print('✅ ${calendars.length} calendarios disponibles');

      // Mostrar información de cada calendario
      for (final calendar in calendars) {
        print(
          '📅 ${calendar.summary} (${calendar.id}) - ${calendar.accessRole}',
        );
      }

      return calendars;
    } catch (error) {
      print('❌ Error obteniendo calendarios: $error');
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
      print('📅 Obteniendo eventos del calendario $calendarId...');
      print('📅 Rango: $timeMin a $timeMax');

      final events = await _calendarApi.events.list(
        calendarId,
        timeMin: timeMin,
        timeMax: timeMax,
        maxResults: maxResults,
        singleEvents: singleEvents,
        orderBy: orderBy,
      );

      final eventList = events.items ?? [];

      print('✅ ${eventList.length} eventos encontrados en el calendario');
      for (final event in eventList) {
        final start = event.start?.dateTime ?? event.start?.date;
        print('  - ${event.summary} ($start)');
      }

      return eventList;
    } catch (error) {
      print('❌ Error obteniendo eventos: $error');
      rethrow;
    }
  }

 // ➕ AGREGAR EVENTO A UN CALENDARIO
  Future<Event> addEvent({
    required String calendarId,
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    String? location,
    List<String>? attendees,
  }) async {
    try {
      print('➕ Agregando evento al calendario $calendarId...');
      
      final event = Event()
        ..summary = title
        ..description = description
        ..location = location
        ..start = EventDateTime(dateTime: start)
        ..end = EventDateTime(dateTime: end);
      
      if (attendees != null && attendees.isNotEmpty) {
        event.attendees = attendees.map((email) => EventAttendee()
          ..email = email
          ..displayName = email
        ).toList();
      }
      
      final createdEvent = await _calendarApi.events.insert(event, calendarId);
      
      print('✅ Evento agregado exitosamente: ${createdEvent.id}');
      return createdEvent;
    } catch (error) {
      print('❌ Error agregando evento: $error');
      rethrow;
    }
  }

  // 🗑️ ELIMINAR EVENTO
  Future<void> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    try {
      print('🗑️ Eliminando evento $eventId del calendario $calendarId...');
      
      await _calendarApi.events.delete(calendarId, eventId);
      
      print('✅ Evento eliminado exitosamente');
    } catch (error) {
      print('❌ Error eliminando evento: $error');
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
      print('🔍 Buscando "$query" en calendario $calendarId...');
      
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
      
      print('✅ ${eventList.length} eventos encontrados con "$query"');
      return eventList;
    } catch (error) {
      print('❌ Error buscando eventos: $error');
      rethrow;
    }
  }


  /*
  // 🎯 OBTENER ESPECÍFICAMENTE EL CALENDARIO DE USUARIO A
  Future<CalendarListEntry> getUserACalendar() async {
    try {
      print('🎯 Buscando calendario de $_userAEmail...');
      
      // Intentar obtener el calendario específico de Usuario A
      final calendar = await _calendarApi.calendars.get(_userACalendarId);
      
      // Crear un CalendarListEntry a partir del Calendar
      final calendarEntry = CalendarListEntry()
        ..id = calendar.id
        ..summary = calendar.summary
        ..description = calendar.description
        ..backgroundColor = calendar.backgroundColor
        ..foregroundColor = calendar.foregroundColor;
      
      print('✅ Calendario de $_userAEmail encontrado: ${calendar.summary}');
      return calendarEntry;
    } catch (error) {
      print('❌ Error obteniendo calendario de $_userAEmail: $error');
      rethrow;
    }
  }

  // 👀 OBTENER EVENTOS DEL CALENDARIO DE USUARIO A
  Future<List<CalendarEvent>> getEventsFromUserACalendar({
    int maxResults = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('📅 Obteniendo eventos del calendario de $_userAEmail...');
      
      final events = await _calendarApi.events.list(
        _userACalendarId, // Usar el calendarId de Usuario A
        timeMin: startDate ?? DateTime.now().subtract(Duration(days: 30)).toUtc(),
        timeMax: endDate,
        maxResults: maxResults,
        singleEvents: true,
        orderBy: 'startTime',
      );
      
      final eventList = events.items?.map((event) => CalendarEvent.fromGoogleEvent(event)).toList() ?? [];
      
      print('✅ ${eventList.length} eventos encontrados en calendario de $_userAEmail');
      return eventList;
    } catch (error) {
      print('❌ Error obteniendo eventos de $_userAEmail: $error');
      rethrow;
    }
  }

  // ➕ AGREGAR EVENTO AL CALENDARIO DE USUARIO A
  Future<CalendarEvent> addEventToUserACalendar({
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    String? location,
    List<String>? attendees, // Puede incluir al Usuario A
  }) async {
    try {
      print('➕ Agregando evento al calendario de $_userAEmail...');
      
      final event = Event()
        ..summary = title
        ..description = description
        ..location = location
        ..start = EventDateTime(dateTime: start)
        ..end = EventDateTime(dateTime: end);
      
      // Agregar attendees si se especifican
      if (attendees != null && attendees.isNotEmpty) {
        event.attendees = attendees.map((email) => EventAttendee()
          ..email = email
          ..displayName = email == _userAEmail ? 'Usuario A (Dueño)' : email
        ).toList();
      }
      
      // Incluir al Usuario A como attendee por defecto
      event.attendees ??= [];
      event.attendees!.add(EventAttendee()
        ..email = _userAEmail
        ..displayName = 'Usuario A (Dueño del calendario)'
        ..organizer = true
      );
      
      final createdEvent = await _calendarApi.events.insert(
        event, 
        _userACalendarId, // Insertar en calendario de Usuario A
      );
      
      print('✅ Evento agregado al calendario de $_userAEmail: ${createdEvent.id}');
      return CalendarEvent.fromGoogleEvent(createdEvent);
    } catch (error) {
      print('❌ Error agregando evento al calendario de $_userAEmail: $error');
      rethrow;
    }
  }

  // 🔍 BUSCAR EVENTOS EN EL CALENDARIO DE USUARIO A
  Future<List<CalendarEvent>> searchEventsInUserACalendar({
    required String query,
    int maxResults = 20,
  }) async {
    try {
      print('🔍 Buscando "$query" en calendario de $_userAEmail...');
      
      final events = await _calendarApi.events.list(
        _userACalendarId,
        q: query, // Query de búsqueda
        maxResults: maxResults,
        singleEvents: true,
        orderBy: 'startTime',
      );
      
      final eventList = events.items?.map((event) => CalendarEvent.fromGoogleEvent(event)).toList() ?? [];
      
      print('✅ ${eventList.length} eventos encontrados con "$query"');
      return eventList;
    } catch (error) {
      print('❌ Error buscando eventos: $error');
      rethrow;
    }
  }

  // 🗑️ ELIMINAR EVENTO DEL CALENDARIO DE USUARIO A
  Future<void> deleteEventFromUserACalendar(String eventId) async {
    try {
      print('🗑️ Eliminando evento $eventId del calendario de $_userAEmail...');
      
      await _calendarApi.events.delete(_userACalendarId, eventId);
      
      print('✅ Evento eliminado exitosamente');
    } catch (error) {
      print('❌ Error eliminando evento: $error');
      rethrow;
    }
  }*/
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
