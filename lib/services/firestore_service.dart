import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAvailableTranslations() async {
    final snapshot = await _db.collection('translations').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getBooks(String translation) async {
    final snapshot = await _db.collection(translation).get();
    return snapshot.docs.map((doc) => {'name': doc.id}).toList();
  }

  Future<int> getChapterCount(String translation, String book) async {
    final snapshot = await _db.collection(translation).doc(book).collection('chapters').get();
    return snapshot.docs.length;
  }

  Future<List<int>> getChapters(String translation, String book) async {
    final snapshot = await _db.collection(translation).doc(book).collection('chapters').get();
    return snapshot.docs.map((doc) => int.parse(doc.id)).toList();
  }

  Future<List<Map<String, dynamic>>> getVerses(String translation, String book, int chapter) async {
    final snapshot = await _db.collection(translation).doc(book).collection('chapters').doc(chapter.toString()).collection('verses').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    final lowerCaseQuery = query.toLowerCase();
    final snapshot = await _db.collectionGroup('verses').where('words', arrayContains: lowerCaseQuery).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
