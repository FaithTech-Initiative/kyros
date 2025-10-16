import 'package:flutter/material.dart';
import 'package:kyros/models/wiki_entry.dart';
import 'package:kyros/screens/wiki_entry_screen.dart';

class MyWikiScreen extends StatefulWidget {
  const MyWikiScreen({super.key});

  @override
  State<MyWikiScreen> createState() => _MyWikiScreenState();
}

class _MyWikiScreenState extends State<MyWikiScreen> {
  final List<WikiEntry> _wikiEntries = [
    const WikiEntry(title: 'First Entry', content: 'This is the content of the first entry.'),
    const WikiEntry(title: 'Second Entry', content: 'This is the content of the second entry.'),
    const WikiEntry(title: 'Third Entry', content: 'This is the content of the third entry.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wiki'),
      ),
      body: ListView.builder(
        itemCount: _wikiEntries.length,
        itemBuilder: (context, index) {
          final entry = _wikiEntries[index];
          return ListTile(
            title: Text(entry.title),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WikiEntryScreen(entry: entry),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement creating a new wiki entry
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
