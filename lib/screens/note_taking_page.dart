
import 'package:flutter/material.dart';
import 'package:kyros/widgets/bible_panel.dart';
import 'package:kyros/widgets/note_editor.dart';

class NoteTakingPage extends StatelessWidget {
  const NoteTakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sermon Notes'),
      ),
      body: const Row(
        children: [
          Expanded(
            child: NoteEditor(),
          ),
          BiblePanel(),
        ],
      ),
    );
  }
}
