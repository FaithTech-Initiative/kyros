import 'package:flutter/material.dart';
import 'package:kyros/data/bible_data.dart';
import 'package:kyros/screens/chapter_selection_screen.dart';
import 'package:kyros/screens/versions_screen.dart';

class BibleReferencesScreen extends StatefulWidget {
  const BibleReferencesScreen({super.key});

  @override
  State<BibleReferencesScreen> createState() => _BibleReferencesScreenState();
}

class _BibleReferencesScreenState extends State<BibleReferencesScreen> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    final filteredBooks = bibleBooks.keys.where((book) {
      return book.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();

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
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: () {
              // TODO: Implement sorting
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Implement history
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
            child: ListView.builder(
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return ListTile(
                  title: Text(book),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterSelectionScreen(
                          book: book,
                          chapterCount: bibleBooks[book]!,
                        ),
                      ),
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
