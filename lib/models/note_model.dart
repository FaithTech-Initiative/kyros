class Note {
  final String id;
  final String title;
  final String content;
  final String? imagePath;
  final String? audioPath;
  final DateTime createdAt;

  Note({required this.id, required this.title, required this.content, this.imagePath, this.audioPath, required this.createdAt});
}
