import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kyros/models/note_model.dart';
import 'package:kyros/widgets/note_editor.dart';
import 'package:uuid/uuid.dart';

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
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = TextEditingController(text: widget.note?.content);
    _imagePath = widget.note?.imagePath;
  }

  @override
  void didUpdateWidget(covariant NoteScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note != oldWidget.note) {
      _titleController.text = widget.note?.title ?? '';
      _contentController.text = widget.note?.content ?? '';
      _imagePath = widget.note?.imagePath;
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;
    if (title.isNotEmpty || content.isNotEmpty || _imagePath != null) {
      final note = Note(
        id: widget.note?.id ?? const Uuid().v4(),
        title: title,
        content: content,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        imagePath: _imagePath,
      );

      final noteData = note.toMap();

      if (widget.userId != null) {
        final noteRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('notes')
            .doc(note.id);
        await noteRef.set(noteData, SetOptions(merge: true));
      }
      if(mounted){
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sermon Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: NoteEditor(
        titleController: _titleController,
        contentController: _contentController,
        imagePath: _imagePath,
        onImagePathChanged: (path) {
          setState(() {
            _imagePath = path;
          });
        },
      ),
    );
  }
}
