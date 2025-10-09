
import 'dart:async';

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
  late TextEditingController _subtitleController;
  late TextEditingController _contentController;
  String? _imagePath;
  Timer? _autoSaveTimer;
  DateTime? _lastEditedAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _subtitleController = TextEditingController(text: widget.note?.subtitle);
    _contentController = TextEditingController(text: widget.note?.content);
    _imagePath = widget.note?.imagePath;
    _lastEditedAt = widget.note?.lastEditedAt;
    _startAutoSave();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _saveNote();
    _titleController.dispose();
    _subtitleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _saveNote();
    });
  }

  Future<void> _saveNote() async {
    final title = _titleController.text;
    final subtitle = _subtitleController.text;
    final content = _contentController.text;
    if (title.isNotEmpty ||
        subtitle.isNotEmpty ||
        content.isNotEmpty ||
        _imagePath != null) {
      final now = DateTime.now();
      final note = Note(
          id: widget.note?.id ?? const Uuid().v4(),
          title: title,
          subtitle: subtitle,
          content: content,
          createdAt: widget.note?.createdAt ?? now,
          imagePath: _imagePath,
          lastEditedAt: now);

      final noteData = note.toMap();

      if (widget.userId != null) {
        final noteRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('notes')
            .doc(note.id);
        await noteRef.set(noteData, SetOptions(merge: true));
        if (mounted) {
          setState(() {
            _lastEditedAt = now;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveNote();
        }
      },
      child: Scaffold(
        body: NoteEditor(
          titleController: _titleController,
          subtitleController: _subtitleController,
          contentController: _contentController,
          imagePath: _imagePath,
          onImagePathChanged: (path) {
            setState(() {
              _imagePath = path;
            });
          },
          lastEditedAt: _lastEditedAt,
        ),
      ),
    );
  }
}
