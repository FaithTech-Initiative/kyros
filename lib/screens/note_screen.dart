
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kyros/models/note_model.dart';
import 'package:audioplayers/audioplayers.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;

  const NoteScreen({
    super.key,
    this.note,
  });

  @override
  NoteScreenState createState() => NoteScreenState();
}

class NoteScreenState extends State<NoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _imagePath;
  String? _audioPath;

  bool isRecording = false;
  bool isPlaying = false;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _imagePath = widget.note?.imagePath;
    _audioPath = widget.note?.audioPath;
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _toggleRecording() async {
    // TODO: Implement audio recording
  }

  Future<void> _playAudio() async {
    if (_audioPath != null) {
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
      setState(() => isPlaying = true);
      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() => isPlaying = false);
      });
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() => isPlaying = false);
  }


  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;
    if (title.isNotEmpty ||
        content.isNotEmpty ||
        _imagePath != null ||
        _audioPath != null) {
      final newNote = Note(
        id: widget.note?.id ?? DateTime.now().toString(),
        title: title,
        content: content,
        imagePath: _imagePath,
        audioPath: _audioPath,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
      );
      Navigator.pop(context, newNote);
    } else {
      Navigator.pop(context);
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
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Note',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            if (_imagePath != null)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: Image.file(File(_imagePath!)),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                  tooltip: 'Add Image',
                ),
                IconButton(
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  onPressed: _toggleRecording,
                  tooltip: isRecording ? 'Stop Recording' : 'Record Audio',
                ),
                if (_audioPath != null)
                  IconButton(
                    icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                    onPressed: isPlaying ? _stopAudio : _playAudio,
                    tooltip: isPlaying ? 'Stop' : 'Play',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
