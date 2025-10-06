
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NoteEditor extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final String? imagePath;
  final ValueChanged<String?> onImagePathChanged;

  const NoteEditor({
    super.key,
    required this.titleController,
    required this.contentController,
    this.imagePath,
    required this.onImagePathChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: contentController,
              decoration: const InputDecoration(
                hintText: 'Note',
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),
          if (imagePath != null)
            SizedBox(
              height: 150,
              child: Image.file(File(imagePath!)),
            ),
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                onImagePathChanged(pickedFile.path);
              }
            },
          ),
        ],
      ),
    );
  }
}
