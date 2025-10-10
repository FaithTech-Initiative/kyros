import 'package:flutter/material.dart';
import 'package:kyros/screens/versions_screen.dart';
import 'package:kyros/services/bible_service.dart';

class VerseScreen extends StatefulWidget {
  final String book;
  final int chapter;

  const VerseScreen({super.key, required this.book, required this.chapter});

  @override
  State<VerseScreen> createState() => _VerseScreenState();
}

class _VerseScreenState extends State<VerseScreen> {
  final BibleService _bibleService = BibleService();
  String _selectedVersion = 'kjv';
  Future<Map<String, dynamic>>? _bibleContent;

  @override
  void initState() {
    super.initState();
    _loadBibleContent();
  }

  void _loadBibleContent() {
    _bibleContent = _bibleService.getDownloadedBibleVersion(_selectedVersion);
  }

  void _onVersionSelected(String version) {
    setState(() {
      _selectedVersion = version;
      _loadBibleContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book} ${widget.chapter}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              // TODO: Implement text-to-speech
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement more options
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bibleContent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.containsKey('error')) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading Bible content. Please download the version first.'),
                  ElevatedButton(
                      onPressed: () async {
                        final selected = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VersionsScreen(),
                          ),
                        );
                        if (selected != null) {
                          _onVersionSelected(selected);
                        }
                      },
                      child: const Text('Go to Versions'))
                ],
              ),
            );
          }

          final bible = snapshot.data!;
          final bookData = bible['books'][widget.book];
          if (bookData == null) {
            return const Center(child: Text('Book not found in this version.'));
          }
          final chapterData = bookData[widget.chapter.toString()];
          if (chapterData == null) {
            return const Center(child: Text('Chapter not found in this version.'));
          }
          final verses = chapterData as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: verses.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('${entry.key} ${entry.value}'),
                );
              }).toList(),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(_selectedVersion.toUpperCase()),
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text('${widget.book} ${widget.chapter}'),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                // TODO: Implement next chapter
              },
            ),
          ],
        ),
      ),
    );
  }
}
