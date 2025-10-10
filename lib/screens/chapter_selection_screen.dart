import 'package:flutter/material.dart';
import 'package:kyros/screens/verse_screen.dart';
import 'package:kyros/services/history_service.dart';

class ChapterSelectionScreen extends StatelessWidget {
  final String book;
  final int chapterCount;

  const ChapterSelectionScreen({super.key, required this.book, required this.chapterCount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: chapterCount,
        itemBuilder: (context, index) {
          final chapter = index + 1;
          return GestureDetector(
            onTap: () {
              HistoryService.add_to_history(book, chapter);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerseScreen(book: book, chapter: chapter),
                ),
              );
            },
            child: Card(
              child: Center(
                child: Text(chapter.toString()),
              ),
            ),
          );
        },
      ),
    );
  }
}
