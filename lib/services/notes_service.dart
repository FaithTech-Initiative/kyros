import 'package:flutter/material.dart';
import 'package:kyros/models/note.dart';

class NotesService extends ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  void addNote(String title, String content) {
    final newNote = Note(
      title: title,
      content: content,
      createdTime: DateTime.now(),
    );
    _notes.add(newNote);
    notifyListeners();
  }

  void updateNote(int id, String title, String content) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = Note(
        id: id,
        title: title,
        content: content,
        createdTime: _notes[index].createdTime,
      );
      notifyListeners();
    }
  }

  void deleteNote(int id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}
