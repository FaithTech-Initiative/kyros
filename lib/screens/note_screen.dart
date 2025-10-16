import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kyros/models/note.dart';
import 'package:kyros/services/notes_database_helper.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;
  final String? userId;
  const NoteScreen({super.key, this.note, this.userId});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isArchived = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _isArchived = widget.note?.isArchived ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isNotEmpty || content.isNotEmpty) {
      final now = DateTime.now();
      final note = Note(
        id: widget.note?.id,
        title: title,
        content: content,
        createdTime: widget.note?.createdTime ?? now,
        isArchived: _isArchived,
      );

      if (widget.note == null) {
        final createdNote = await NotesDatabaseHelper.instance.create(note);
        if (widget.userId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('notes')
              .doc(createdNote.id.toString())
              .set(createdNote.toMap());
        }
      } else {
        await NotesDatabaseHelper.instance.update(note);
        if (widget.userId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('notes')
              .doc(note.id.toString())
              .update(note.toMap());
        }
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _deleteNote() async {
    if (widget.note != null) {
      final updatedNote = widget.note!.copy(isDeleted: true);
      await NotesDatabaseHelper.instance.update(updatedNote);
      if (widget.userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('notes')
            .doc(widget.note!.id.toString())
            .update({'isDeleted': true});
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _toggleArchive() async {
    setState(() {
      _isArchived = !_isArchived;
    });
    if (widget.note != null) {
      final updatedNote = widget.note!.copy(isArchived: _isArchived);
      await NotesDatabaseHelper.instance.update(updatedNote);
      if (widget.userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('notes')
            .doc(widget.note!.id.toString())
            .update({'isArchived': _isArchived});
      }
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          _saveNote();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.push_pin_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(_isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
          onPressed: _toggleArchive,
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Note',
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.mic_none),
    ),
    bottomNavigationBar: BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.delete_outline),
                        title: const Text('Delete'),
                        onTap: () {
                          Navigator.of(context).pop();
                          _deleteNote();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.copy),
                        title: const Text('Make a copy'),
                        onTap: () {
                          Navigator.of(context).pop();
                          // _copyNote();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.send),
                        title: const Text('Send'),
                        onTap: () {
                          Navigator.of(context).pop();
                          // _sendNote();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_add_outlined),
                        title: const Text('Collaborator'),
                        onTap: () {
                          Navigator.of(context).pop();
                          // _addCollaborator();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.label_outline),
                        title: const Text('Labels'),
                        onTap: () {
                          Navigator.of(context).pop();
                          // _manageLabels();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Help & feedback'),
                        onTap: () {
                          Navigator.of(context).pop();
                          // _showHelp();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}
}
