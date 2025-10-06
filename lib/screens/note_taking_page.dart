
import 'package:flutter/material.dart';
import 'package:kyros/models/note_model.dart';
import 'package:kyros/widgets/bible_panel.dart';
import 'package:kyros/widgets/note_editor.dart';
import 'package:uuid/uuid.dart';

class NoteTakingPage extends StatefulWidget {
  final Note? note;
  const NoteTakingPage({super.key, this.note});

  @override
  State<NoteTakingPage> createState() => _NoteTakingPageState();
}

class _NoteTakingPageState extends State<NoteTakingPage> {
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
  void didUpdateWidget(covariant NoteTakingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note != oldWidget.note) {
      _titleController.text = widget.note?.title ?? '';
      _contentController.text = widget.note?.content ?? '';
      _imagePath = widget.note?.imagePath;
    }
  }

  void _saveNote() {
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
      // Here you would typically save the note to a database or state management solution
      Navigator.of(context).pop(note);
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
      body: Row(
        children: [
          Expanded(
            child: NoteEditor(
              titleController: _titleController,
              contentController: _contentController,
              imagePath: _imagePath,
              onImagePathChanged: (path) {
                setState(() {
                  _imagePath = path;
                });
              },
            ),
          ),
          const BiblePanel(),
        ],
      ),
    );
  }
}
