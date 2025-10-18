import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  final db = FirebaseFirestore.instance;

  final translations = await db.collection('translations').get();

  for (var translation in translations.docs) {
    final books = await db.collection(translation.id).get();
    for (var book in books.docs) {
      final chapters = await db.collection(translation.id).doc(book.id).collection('chapters').get();
      for (var chapter in chapters.docs) {
        final verses = await db.collection(translation.id).doc(book.id).collection('chapters').doc(chapter.id).collection('verses').get();
        for (var verse in verses.docs) {
          final text = verse.data()['text'] as String;
          final words = text.toLowerCase().split(RegExp(r'\W+'));
          await verse.reference.update({'words': words});
        }
      }
    }
  }
}
