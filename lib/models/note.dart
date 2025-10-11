class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdTime;
  final List<String> labels;
  final bool isArchived;
  final bool isDeleted;
  final List<String> imageUrls;
  final List<String> audioUrls;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdTime,
    this.labels = const [],
    this.isArchived = false,
    this.isDeleted = false,
    this.imageUrls = const [],
    this.audioUrls = const [],
  });

  Note copy({
    int? id,
    String? title,
    String? content,
    DateTime? createdTime,
    List<String>? labels,
    bool? isArchived,
    bool? isDeleted,
    List<String>? imageUrls,
    List<String>? audioUrls,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        createdTime: createdTime ?? this.createdTime,
        labels: labels ?? this.labels,
        isArchived: isArchived ?? this.isArchived,
        isDeleted: isDeleted ?? this.isDeleted,
        imageUrls: imageUrls ?? this.imageUrls,
        audioUrls: audioUrls ?? this.audioUrls,
      );

  static Note fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as int?,
        title: map['title'] as String,
        content: map['content'] as String,
        createdTime: DateTime.parse(map['createdTime'] as String),
        labels: map['labels'] != null ? List<String>.from(map['labels']) : [],
        isArchived: map['isArchived'] == 1,
        isDeleted: map['isDeleted'] == 1,
        imageUrls: map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : [],
        audioUrls: map['audioUrls'] != null ? List<String>.from(map['audioUrls']) : [],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'createdTime': createdTime.toIso8601String(),
        'labels': labels,
        'isArchived': isArchived ? 1 : 0,
        'isDeleted': isDeleted ? 1 : 0,
        'imageUrls': imageUrls,
        'audioUrls': audioUrls,
      };
}
