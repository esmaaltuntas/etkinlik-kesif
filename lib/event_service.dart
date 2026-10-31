
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'event_model.dart';

class EventService {
  static const String baseUrl =
      'https://mobilab-task-api.vercel.app';

  Future<List<Event>> getEvents() async {
    final url = Uri.parse('$baseUrl/events?limit=50');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final List<dynamic> items = decoded['items'];

      return items
          .map((item) => Event.fromJson(item))
          .toList();
    } else {
      throw Exception(
        'Etkinlikler alınamadı: ${response.statusCode}',
      );
    }
  }

  Future<Event> getEventDetail(String id) async {
    final url = Uri.parse('$baseUrl/events/$id');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      return Event.fromJson(decoded);
    } else {
      throw Exception(
        'Etkinlik detayı alınamadı: ${response.statusCode}',
      );
    }
  }
}
