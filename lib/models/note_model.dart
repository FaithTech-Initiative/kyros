
import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String? subtitle;
  final String content;
  final String? imagePath;
  final String? audioPath;
  final DateTime createdAt;
  final DateTime? lastEditedAt;

  Note({
    required this.id,
    required this.title,
    this.subtitle,
    required this.content,
    this.imagePath,
    this.audioPath,
    required this.createdAt,
    this.lastEditedAt,
  });

  factory Note.fromMap(Map<String, dynamic> data, String documentId) {
    return Note(
      id: documentId,
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      content: data['content'] ?? '',
      imagePath: data['imagePath'],
      audioPath: data['audioPath'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastEditedAt: data['lastEditedAt'] != null
          ? (data['lastEditedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'createdAt': createdAt,
      'lastEditedAt': lastEditedAt,
    };
  }
}
