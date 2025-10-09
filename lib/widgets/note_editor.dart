
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class NoteEditor extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController subtitleController;
  final TextEditingController contentController;
  final String? imagePath;
  final ValueChanged<String?> onImagePathChanged;
  final DateTime? lastEditedAt;

  const NoteEditor({
    super.key,
    required this.titleController,
    required this.subtitleController,
    required this.contentController,
    this.imagePath,
    required this.onImagePathChanged,
    this.lastEditedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.push_pin_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            const SizedBox(height: 8),
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(
                hintText: 'Subtitle',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
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
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      onImagePathChanged(pickedFile.path);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.color_lens_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.text_fields),
                  onPressed: () {},
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return _MoreOptionsSheet(
                      lastEditedAt: lastEditedAt,
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

class _MoreOptionsSheet extends StatelessWidget {
  final DateTime? lastEditedAt;
  const _MoreOptionsSheet({this.lastEditedAt});

  @override
  Widget build(BuildContext context) {
    final formattedTime = lastEditedAt != null
        ? DateFormat.jm().format(lastEditedAt!)
        : 'Not available';
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edited $formattedTime', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete'),
            onTap: () {
              // TODO: Implement Delete
            },
          ),
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text('Make a copy'),
            onTap: () {
              // TODO: Implement Make a copy
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Send'),
            onTap: () {
              // TODO: Implement Send
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_outlined),
            title: const Text('Collaborator'),
            onTap: () {
              // TODO: Implement Collaborator
            },
          ),
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: const Text('Labels'),
            onTap: () {
              // TODO: Implement Labels
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & feedback'),
            onTap: () {
              // TODO: Implement Help & feedback
            },
          ),
        ],
      ),
    );
  }
}
