
class Note {
  final String id;
  String title;
  List<Map<String, dynamic>> content; // Block-based content
  List<String> tags;
  String status;

  Note({
    required this.id,
    this.title = 'Untitled',
    this.content = const [],
    this.tags = const [],
    this.status = '#TODO',
  });
}
