import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kyros/data/bible_data.dart';
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
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  String _chapterText = '';
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadBibleContent();
    _initTts();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
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

  Future<void> _speak() async {
    if (_chapterText.isNotEmpty) {
      setState(() {
        _isSpeaking = true;
      });
      await _flutterTts.speak(_chapterText);
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  void _navigateToChapter(int chapter) {
    if (chapter > 0 && chapter <= bibleBooks[widget.book]!) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerseScreen(book: widget.book, chapter: chapter),
        ),
      );
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchText = '';
        _searchController.clear();
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search in chapter...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              )
            : Text('${widget.book} ${widget.chapter}'),
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (!_isSearchActive)
            IconButton(
              icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
              onPressed: _isSpeaking ? _stop : _speak,
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

          _chapterText = verses.entries.map((e) => '${e.key} ${e.value}').join(' ');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: verses.entries.map((entry) {
                  final verseText = '${entry.key} ${entry.value}';
                  final List<TextSpan> textSpans = [];
                  if (_searchText.isNotEmpty && verseText.toLowerCase().contains(_searchText.toLowerCase())) {
                    final matches = _searchText.toLowerCase().allMatches(verseText.toLowerCase());
                    int lastMatchEnd = 0;
                    for (var match in matches) {
                      if (match.start > lastMatchEnd) {
                        textSpans.add(TextSpan(text: verseText.substring(lastMatchEnd, match.start)));
                      }
                      textSpans.add(
                        TextSpan(
                          text: verseText.substring(match.start, match.end),
                          style: const TextStyle(backgroundColor: Colors.yellow),
                        ),
                      );
                      lastMatchEnd = match.end;
                    }
                    if (lastMatchEnd < verseText.length) {
                      textSpans.add(TextSpan(text: verseText.substring(lastMatchEnd)));
                    }
                  } else {
                    textSpans.add(TextSpan(text: verseText));
                  }
                  return TextSpan(children: textSpans..add(const TextSpan(text: '\n\n')));
                }).toList(),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                _navigateToChapter(widget.chapter - 1);
              },
            ),
            Text('${widget.book} ${widget.chapter}'),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                _navigateToChapter(widget.chapter + 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
