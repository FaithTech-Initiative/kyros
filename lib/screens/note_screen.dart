import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kyros/models/note.dart';
import 'package:kyros/services/database_helper.dart';

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
  late TextEditingController _labelsController;
  List<String> _labels = [];
  bool _isArchived = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _labels = widget.note?.labels ?? [];
    _isArchived = widget.note?.isArchived ?? false;
    _labelsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _labelsController.dispose();
    super.dispose();
  }

  void _addLabel() {
    if (_labelsController.text.isNotEmpty) {
      setState(() {
        _labels.add(_labelsController.text);
        _labelsController.clear();
      });
    }
  }

  void _removeLabel(String label) {
    setState(() {
      _labels.remove(label);
    });
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
        labels: _labels,
        isArchived: _isArchived,
      );

      if (widget.note == null) {
        final createdNote = await DatabaseHelper.instance.create(note);
        if (widget.userId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('notes')
              .doc(createdNote.id.toString())
              .set(createdNote.toMap());
        }
      } else {
        await DatabaseHelper.instance.update(note);
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
      await DatabaseHelper.instance.update(updatedNote);
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

  void _copyNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isNotEmpty || content.isNotEmpty) {
      final now = DateTime.now();
      final note = Note(
        title: title,
        content: content,
        createdTime: now,
        labels: _labels,
        isArchived: _isArchived,
      );
      final createdNote = await DatabaseHelper.instance.create(note);
      if (widget.userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('notes')
            .doc(createdNote.id.toString())
            .set(createdNote.toMap());
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
      await DatabaseHelper.instance.update(updatedNote);
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
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
          if (widget.note != null)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'archive',
                  child: Text(_isArchived ? 'Unarchive' : 'Archive'),
                ),
                const PopupMenuItem(
                  value: 'copy',
                  child: Text('Make a copy'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) {
                if (value == 'archive') {
                  _toggleArchive();
                } else if (value == 'copy') {
                  _copyNote();
                } else if (value == 'delete') {
                  _deleteNote();
                }
              },
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
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              children: _labels
                  .map((label) => Chip(
                        label: Text(label),
                        onDeleted: () => _removeLabel(label),
                      ))
                  .toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _labelsController,
                    decoration: const InputDecoration(
                      labelText: 'Add a label',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
