import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyVerseService {
  final String _url = 'https://beta.ourmanna.com/api/v1/get?format=json&order=random';

  Future<Map<String, String>> getDailyVerse() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final verseDetails = data['verse']['details'];
      return {
        'reference': verseDetails['reference'] as String,
        'text': verseDetails['text'] as String,
      };
    } else {
      throw Exception('Failed to load daily verse');
    }
  }
}
