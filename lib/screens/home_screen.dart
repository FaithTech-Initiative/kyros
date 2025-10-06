
import 'package:flutter/material.dart';
import 'package:kyros/models/note_model.dart';
import 'package:kyros/screens/note_taking_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for recent notes
    final List<Note> recentNotes = [
      Note(
        id: '1',
        title: 'Sermon on the Mount',
        content: 'Blessed are the meek, for they shall inherit the earth...',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Note(
        id: '2',
        title: 'Parable of the Sower',
        content: 'A sower went out to sow his seed. And as he sowed... ',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Note(
        id: '3',
        title: 'John 3:16',
        content: 'For God so loved the world that he gave his one and only Son...',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Notes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: recentNotes.length,
              itemBuilder: (context, index) {
                final note = recentNotes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(note.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NoteTakingPage(note: note),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
