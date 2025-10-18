import 'package:flutter/material.dart';
import 'package:kyros/screens/verse_selection_screen.dart';
import 'package:kyros/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterSelectionScreen extends StatefulWidget {
  final String book;
  final int chapterCount;

  const ChapterSelectionScreen({
    super.key,
    required this.book,
    required this.chapterCount,
  });

  @override
  State<ChapterSelectionScreen> createState() => _ChapterSelectionScreenState();
}

class _ChapterSelectionScreenState extends State<ChapterSelectionScreen> {
  late Future<List<Map<String, dynamic>>> _booksFuture;
  String? _expandedBook;
  final Map<String, int> _chapterCounts = {};
  String _searchText = '';
  String _translation = 'ESV_bible';
  bool _sortAsc = true;

  @override
  void initState() {
    super.initState();
    _expandedBook = widget.book;
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _translation = prefs.getString('active_translation') ?? 'ESV_bible';
    _booksFuture = DatabaseHelper.instance.getBooks(_translation);
    if (_expandedBook != null) {
      _getChapterCount(_expandedBook!);
    }
    setState(() {});
  }

  Future<void> _getChapterCount(String book) async {
    if (!_chapterCounts.containsKey(book)) {
      final count = await DatabaseHelper.instance.getChapterCount(_translation, book);
      setState(() {
        _chapterCounts[book] = count;
      });
    }
  }

  void _toggleBook(String book) {
    setState(() {
      if (_expandedBook == book) {
        _expandedBook = null;
      } else {
        _expandedBook = book;
        _getChapterCount(book);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('References'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: () {
              setState(() {
                _sortAsc = !_sortAsc;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).canvasColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _booksFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var books = snapshot.data!;
                if (_searchText.isNotEmpty) {
                  books = books.where((book) {
                    return book[DatabaseHelper.columnBook]
                        .toLowerCase()
                        .contains(_searchText.toLowerCase());
                  }).toList();
                }

                books.sort((a, b) {
                  final bookA = a[DatabaseHelper.columnBook] as String;
                  final bookB = b[DatabaseHelper.columnBook] as String;
                  return _sortAsc ? bookA.compareTo(bookB) : bookB.compareTo(bookA);
                });

                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final bookData = books[index];
                    final bookName = bookData[DatabaseHelper.columnBook];
                    final isExpanded = _expandedBook == bookName;
                    final chapterCount = _chapterCounts[bookName] ?? 0;

                    return Column(
                      children: [
                        ListTile(
                          title: Text(bookName),
                          trailing: const Icon(Icons.volume_up_outlined, color: Colors.grey),
                          onTap: () => _toggleBook(bookName),
                        ),
                        if (isExpanded)
                          GridView.builder(
                            padding: const EdgeInsets.all(16.0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: chapterCount,
                            itemBuilder: (context, chapterIndex) {
                              final chapter = chapterIndex + 1;
                              return GestureDetector(
                                onTap: () {
                                   Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VerseSelectionScreen(
                                        book: bookName,
                                        chapter: chapter,
                                        translation: _translation,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(chapter.toString()),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
