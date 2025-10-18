import 'package:flutter/material.dart';
import 'package:kyros/screens/bible_references_screen.dart';
import 'package:kyros/services/database_helper.dart';

class VerseSelectionScreen extends StatefulWidget {
  final String book;
  final int chapter;
  final String translation;

  const VerseSelectionScreen({
    super.key,
    required this.book,
    required this.chapter,
    required this.translation,
  });

  @override
  State<VerseSelectionScreen> createState() => _VerseSelectionScreenState();
}

class _VerseSelectionScreenState extends State<VerseSelectionScreen> {
  late Future<int> _verseCountFuture;

  @override
  void initState() {
    super.initState();
    _verseCountFuture = _getVerseCount();
  }

  Future<int> _getVerseCount() async {
    return await DatabaseHelper.instance.getVerseCount(
      widget.translation,
      widget.book,
      widget.chapter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book} ${widget.chapter}'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: FutureBuilder<int>(
        future: _verseCountFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == 0) {
            return const Center(child: Text('Could not load verses.'));
          }

          final verseCount = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: verseCount,
            itemBuilder: (context, index) {
              final verseNumber = index + 1;
              return GestureDetector(
                onTap: () {
                   Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BibleReferencesScreen(
                        book: widget.book,
                        chapter: widget.chapter,
                        initialVerse: verseNumber,
                      ),
                    ),
                    (Route<dynamic> route) => route.isFirst,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(verseNumber.toString()),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
