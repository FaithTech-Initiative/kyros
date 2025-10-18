import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kyros/services/database_helper.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseHelper _localDb = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getAvailableTranslations() async {
    // First, try to get translations from local DB
    final localTranslations = await _localDb.getAvailableTranslations();
    if (localTranslations.isNotEmpty) {
      return localTranslations.map((name) => {'name': name}).toList();
    }

    // If not in local DB, fetch from Firestore
    final snapshot = await _db.collection('versions').get();
    final translations = snapshot.docs.map((doc) => doc.data()).toList();

    // Save to local DB for offline access
    for (var translation in translations) {
       await _localDb.loadNewTranslation(translation['name']);
    }
    return translations;
  }

  Future<List<Map<String, dynamic>>> getBooks(String translation) async {
    final books = await _localDb.getBooks(translation);
    if (books.isNotEmpty) {
      return books;
    }
    // This part needs to be implemented if books are not locally available
    // For now, we assume that if a translation is selected, its books are available
    return [];
  }

   Future<int> getChapterCount(String translation, String book) async {
    return await _localDb.getChapterCount(translation, book);
  }

  Future<List<Map<String, dynamic>>> getVerses(String translation, String book, int chapter) async {
    final verses = await _localDb.getVerses(translation, book, chapter);
    if (verses.isNotEmpty) {
        return verses;
    }

    // Fetch from Firestore and save to local DB
    final versionDoc = await _db.collection('versions').doc(translation).get();
    if(versionDoc.exists) {
        final chapterDoc = await versionDoc.reference.collection('books').doc(book).collection('chapters').doc(chapter.toString()).get();
        
        if(chapterDoc.exists) {
            final verseData = chapterDoc.data()!['verses'] as List<dynamic>;
            final db = await _localDb.database;
            
            for(var verse in verseData) {
                 await db.insert(DatabaseHelper.table, {
                    DatabaseHelper.columnBook: book,
                    DatabaseHelper.columnChapter: chapter,
                    DatabaseHelper.columnVerse: verse['verse'],
                    DatabaseHelper.columnText: verse['text'],
                    DatabaseHelper.columnTranslation: translation,
                });
            }
            return await _localDb.getVerses(translation, book, chapter);
        }
    }
    return [];
  }

  Future<int> getVerseCount(String translation, String book, int chapter) async {
    return await _localDb.getVerseCount(translation, book, chapter);
  }



}
