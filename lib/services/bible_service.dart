import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class BibleService {
  final String _baseUrl = 'https://bible-api.com/';

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

  Future<Map<String, dynamic>> getVerse(String reference, {String? translation}) async {
    String url = '$_baseUrl$reference';
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

  Future<void> downloadBibleVersion(String versionName) async {
    developer.log('Downloading $versionName...', name: 'bible.service');

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/$versionName.json');

    Map<String, dynamic> bibleContent = {'name': versionName, 'books': {}};

    try {
        final response = await http.get(Uri.parse('$_baseUrl/Genesis 1?translation=$versionName'));
        if(response.statusCode == 200) {
            bibleContent['books']['Genesis'] = {'1': json.decode(response.body)};
        }
    } catch (e, s) {
        developer.log('Error downloading chapter', name: 'bible.service', error: e, stackTrace: s);
    }


    await file.writeAsString(json.encode(bibleContent));

    developer.log('$versionName downloaded to $path', name: 'bible.service');
  }

  Future<String> getDownloadedBibleVersion(String versionName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$versionName.json');

      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return 'File not found';
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
      developer.log('Error deleting $versionName', name: 'bible.service', error: e, stackTrace: s);
      throw Exception('Failed to delete Bible version.');
    }
  }
}
