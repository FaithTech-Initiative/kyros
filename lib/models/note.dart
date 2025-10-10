import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String? id;
  String title;
  String content;
  Timestamp createdAt;
  bool isArchived;
  bool isDeleted;
  List<String> imageUrls;
  List<String> audioUrls;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isArchived = false,
    this.isDeleted = false,
    this.imageUrls = const [],
    this.audioUrls = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'isArchived': isArchived,
      'isDeleted': isDeleted,
      'imageUrls': imageUrls,
      'audioUrls': audioUrls,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: map['createdAt'],
      isArchived: map['isArchived'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      audioUrls: List<String>.from(map['audioUrls'] ?? []),
    );
  }
}
