import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kyros/models/note_model.dart';
import 'package:kyros/screens/audio_screen.dart';
import 'package:kyros/screens/image_screen.dart';
import 'package:kyros/screens/note_screen.dart';
import 'package:kyros/widgets/expanding_fab.dart';

class HomeScreen extends StatefulWidget {
  final String? userId;

  const HomeScreen({super.key, this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<QuerySnapshot> _notesStream;

  @override
  void initState() {
    super.initState();
    _notesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void _navigateToNotePage({Note? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteScreen(note: note, userId: widget.userId),
      ),
    );
  }

  void _pickImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _notesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notes yet. Tap the + button to add one!',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView(                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      final note = Note.fromMap(data, document.id);
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
                          onTap: () => _navigateToNotePage(note: note),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ExpandingFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => _navigateToNotePage(),
            icon: const Icon(Icons.edit),
            label: 'New Note',
          ),
          ActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioScreen(userId: widget.userId ?? ''),
                ),
              );
            },
            icon: const Icon(Icons.mic),
            label: 'Audio',
          ),
          const SizedBox(height: 8.0),
          ActionButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: 'Image',
          ),
        ],
      ),
    );
  }
}
