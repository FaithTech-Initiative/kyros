import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String? imagePath;
  final String? audioPath;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.imagePath,
    this.audioPath,
    required this.createdAt,
  });

  factory Note.fromMap(Map<String, dynamic> data, String documentId) {
    return Note(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imagePath: data['imagePath'],
      audioPath: data['audioPath'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'createdAt': createdAt,
    };
  }
}
