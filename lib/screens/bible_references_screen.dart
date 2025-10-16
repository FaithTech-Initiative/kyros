import 'package:flutter/material.dart';
import 'package:kyros/services/database_helper.dart';
import 'package:kyros/screens/chapter_selection_screen.dart';
import 'package:kyros/screens/versions_screen.dart';
import 'package:kyros/screens/history_screen.dart';

class BibleReferencesScreen extends StatefulWidget {
  const BibleReferencesScreen({super.key});

  @override
  State<BibleReferencesScreen> createState() => _BibleReferencesScreenState();
}

class _BibleReferencesScreenState extends State<BibleReferencesScreen> {
  String _searchText = '';
  late Future<List<String>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _getBooks();
  }

  Future<List<String>> _getBooks() async {
    final dbHelper = DatabaseHelper.instance;
    final books = await dbHelper.getBooks('KJV');
    return books.map((bookMap) => bookMap[DatabaseHelper.columnBook] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('References'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VersionsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final allBooks = snapshot.data ?? [];
                  final filteredBooks = allBooks.where((book) {
                    return book.toLowerCase().contains(_searchText.toLowerCase());
                  }).toList();
                  return ListView.builder(
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return ListTile(
                        title: Text(book),
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          final dbHelper = DatabaseHelper.instance;
                          final chapterCount = await dbHelper.getChapterCount('KJV', book);
                          if (!mounted) return;
                          navigator.push(
                            MaterialPageRoute(
                              builder: (context) => ChapterSelectionScreen(
                                book: book,
                                chapterCount: chapterCount,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
