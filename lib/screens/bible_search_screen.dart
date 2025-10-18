import 'package:flutter/material.dart';
import 'package:kyros/services/firestore_service.dart';

class BibleSearchScreen extends StatefulWidget {
  const BibleSearchScreen({super.key});

  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _searchVerses(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = await _firestoreService.searchVerses(query);
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bible'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchVerses,
              decoration: InputDecoration(
                hintText: 'Search for verses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final verse = _searchResults[index];
                return ListTile(
                  title: Text(verse['text'] ?? ''),
                  subtitle: Text('${verse['book']} ${verse['chapter']}:${verse['verse']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
