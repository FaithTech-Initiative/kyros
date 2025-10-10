import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kyros/models/note.dart';
import 'package:kyros/services/database_helper.dart';
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
  Timer? _autoSaveTimer;
  DateTime? _lastEditedAt;

  @override
  void initState() {
    super.initState();
    _loadNote();
    _startAutoSave();
  }

  void _loadNote() async {
    if (widget.note != null) {
      try {
        final note = await DatabaseHelper.instance.readNote(widget.note!.id!);
        _titleController = TextEditingController(text: note.title);
        _contentController = TextEditingController(text: note.content);
        _imagePath = note.imageUrls.isNotEmpty ? note.imageUrls.first : null;
        _lastEditedAt = note.createdAt.toDate();
      } catch (e) {
        // Note not found in local DB, use widget's data
        _titleController = TextEditingController(text: widget.note!.title);
        _contentController = TextEditingController(text: widget.note!.content);
         _imagePath = widget.note!.imageUrls.isNotEmpty ? widget.note!.imageUrls.first : null;
        _lastEditedAt = widget.note!.createdAt.toDate();
      }
    } else {
      _titleController = TextEditingController();
      _contentController = TextEditingController();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _saveNote();
    _titleController.dispose();
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
    final content = _contentController.text;
    if (title.isNotEmpty || content.isNotEmpty || _imagePath != null) {
      final now = Timestamp.now();
      final note = Note(
        id: widget.note?.id ?? const Uuid().v4(),
        title: title,
        content: content,
        createdAt: widget.note?.createdAt ?? now,
        imageUrls: _imagePath != null ? [_imagePath!] : [],
      );

      // Save to local database
      try {
        await DatabaseHelper.instance.readNote(note.id!);
        await DatabaseHelper.instance.update(note);
      } catch (e) {
        await DatabaseHelper.instance.create(note);
      }

      if (widget.userId != null) {
        final noteRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('notes')
            .doc(note.id);
        await noteRef.set(note.toMap(), SetOptions(merge: true));
        if (mounted) {
          setState(() {
            _lastEditedAt = now.toDate();
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
