class WikiEntry {
  final int? id;
  final String title;
  final String content;

  const WikiEntry({
    this.id,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  static WikiEntry fromMap(Map<String, dynamic> map) {
    return WikiEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
    );
  }
}
