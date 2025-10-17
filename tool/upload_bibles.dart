
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:kyros/firebase_options.dart';

// IMPORTANT: This script MUST be run using the following command:
// flutter run -t tool/upload_bibles.dart

Future<void> main() async {
  // This ensures all Flutter and Firebase services are correctly initialized.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  developer.log("Firebase App Initialized successfully. Starting upload...");

  final firestore = FirebaseFirestore.instance;
  final versionsDirectory = Directory('assets/translations/EN-English');

  if (!await versionsDirectory.exists()) {
    developer.log('Error: Directory not found: ${versionsDirectory.path}');
    return;
  }

  final files = versionsDirectory.listSync().where((item) => item.path.endsWith('.json'));

  for (final file in files) {
    try {
      final versionId = file.path.split('/').last.split('.').first.toUpperCase();
      final content = await File(file.path).readAsString();
      final jsonData = json.decode(content);

      // 1. Upload Version Metadata
      final versionDocRef = firestore.collection('versions').doc(versionId);
      await versionDocRef.set({
        'name': _getVersionName(versionId),
        'language': 'en',
        'fileName': file.path.split('/').last,
      });

      developer.log('Uploaded metadata for $versionId');

      // 2. Upload Bible Content (Book by Book)
      final books = jsonData['books'] as List;
      final bibleCollectionRef = firestore.collection('bibles').doc(versionId).collection('books');

      for (final bookData in books) {
        final bookName = bookData['name'];
        final bookChapters = bookData['chapters'] as List;

        final chaptersMap = <String, dynamic>{};
        for (int i = 0; i < bookChapters.length; i++) {
          final chapterNum = (i + 1).toString();
          chaptersMap[chapterNum] = bookChapters[i];
        }

        await bibleCollectionRef.doc(bookName).set({'chapters': chaptersMap});
        developer.log('  - Uploaded book: $bookName', name: versionId);
      }

      developer.log('Successfully uploaded all books for version $versionId.');

    } catch (e, s) {
      developer.log('Error processing file ${file.path}', error: e, stackTrace: s);
    }
  }

  developer.log('Bible upload process completed.');
  // Exit the app after the script is done.
  exit(0);
}

String _getVersionName(String versionId) {
  switch (versionId.toLowerCase()) {
    case 'asv': return 'American Standard Version';
    case 'asvs': return '''American Standard Version (Strong's)''';
    case 'bishops': return '''Bishops' Bible''';
    case 'coverdale': return 'Coverdale Bible';
    case 'geneva': return 'Geneva Bible';
    case 'kjv': return 'King James Version';
    case 'kjv_strongs': return '''King James Version (Strong's)''';
    case 'net': return 'New English Translation';
    case 'tyndale': return 'Tyndale Bible';
    case 'web': return 'World English Bible';
    default: return versionId;
  }
}
