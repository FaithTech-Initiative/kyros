import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BibleService {
  final String _baseUrl = 'https://www.biblesupersearch.com/download/';

  final List<String> _availableVersions = [
    'bbe', // Bible in Basic English
    'kjv', // King James Version
    'web', // World English Bible
    'oeb-us', // Open English Bible (US)
  ];

  List<String> getAvailableVersions() {
    return _availableVersions;
  }

  Future<Map<String, bool>> getDownloadedVersionsStatus() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    Map<String, bool> status = {};
    for (var version in _availableVersions) {
      final file = File('$path/$version.json');
      status[version] = await file.exists();
    }
    return status;
  }

  Future<Map<String, dynamic>> getVerse(String reference,
      {String? translation}) async {
    if (translation != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$translation.json');
      if (await file.exists()) {
        return _getVerseFromLocalJson(reference, translation);
      }
    }

    String url = 'https://bible-api.com/$reference';
    if (translation != null) {
      url += '?translation=$translation';
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load verse');
    }
  }

  Future<Map<String, dynamic>> _getVerseFromLocalJson(
      String reference, String translation) async {
    final parsedRef = _parseReference(reference);
    if (parsedRef == null) {
      throw Exception('Invalid reference format');
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/$translation.json');
    final contents = await file.readAsString();
    final bibleData = json.decode(contents);

    final bookName = parsedRef['book'];
    final chapterNum = parsedRef['chapter'];
    final verseNum = parsedRef['verse'];

    // Find the book in the downloaded JSON
    int bookIndex = -1;
    for (int i = 0; i < bibleData.length; i++) {
      if (bibleData[i]['name'].toString().toLowerCase() == bookName.toLowerCase()) {
        bookIndex = i;
        break;
      }
    }

    if (bookIndex == -1) {
      throw Exception('Book not found');
    }

    final book = bibleData[bookIndex];
    final chapter = book['chapters'][chapterNum - 1];
    final verse = chapter[verseNum - 1];

    return {
      'reference': '$bookName $chapterNum:$verseNum',
      'verses': [
        {
          'book_id': bookName,
          'book_name': bookName,
          'chapter': chapterNum,
          'verse': verseNum,
          'text': verse['text'],
        }
      ],
      'text': verse['text'],
      'translation_id': translation,
      'translation_name': translation,
      'translation_note': 'Local file',
    };
  }

  Map<String, dynamic>? _parseReference(String reference) {
    final regex = RegExp(r'^(\d?\s?[a-zA-Z]+(?:\s[a-zA-Z]+)?)\s(\d+):(\d+)$');
    final match = regex.firstMatch(reference);
    if (match != null) {
      return {
        'book': match.group(1)!.trim(),
        'chapter': int.parse(match.group(2)!),
        'verse': int.parse(match.group(3)!),
      };
    }
    return null;
  }

  Future<void> downloadBibleVersion(String versionName) async {
    if (await Permission.storage.request().isGranted) {
      developer.log('Downloading $versionName...', name: 'bible.service');

      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final zipFile = File('$path/$versionName.zip');
      final bibleFile = File('$path/$versionName.json');

      try {
        final response = await http.get(Uri.parse('$_baseUrl$versionName.zip'));
        if (response.statusCode == 200) {
          await zipFile.writeAsBytes(response.bodyBytes);

          final bytes = zipFile.readAsBytesSync();
          final archive = ZipDecoder().decodeBytes(bytes);

          for (final file in archive) {
            final filename = file.name;
            if (filename.endsWith('.json')) {
              final data = file.content as List<int>;
              await bibleFile.writeAsBytes(data);
              break;
            }
          }

          await zipFile.delete();
        } else {
          throw Exception('Failed to download Bible version');
        }
      } catch (e, s) {
        developer.log('Error downloading chapter',
            name: 'bible.service', error: e, stackTrace: s);
      }

      developer.log('$versionName downloaded to $path', name: 'bible.service');
    }
  }

  Future<Map<String, dynamic>> getDownloadedBibleVersion(
      String versionName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$versionName.json');

      final contents = await file.readAsString();
      return json.decode(contents);
    } catch (e) {
      return {'error': 'File not found'};
    }
  }

  Future<void> deleteBibleVersion(String versionName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$versionName.json');

      if (await file.exists()) {
        await file.delete();
        developer.log('$versionName deleted.', name: 'bible.service');
      }
    } catch (e, s) {
      developer.log('Error deleting $versionName',
          name: 'bible.service', error: e, stackTrace: s);
      throw Exception('Failed to delete Bible version.');
    }
  }
}
