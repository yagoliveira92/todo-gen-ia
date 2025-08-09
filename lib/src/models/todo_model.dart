class TodoItem {
  final String id;
  final String title;
  final DateTime createAt;
  final DateTime? deadline;
  final String? location;
  final String content;
  bool isDone;

  TodoItem({
    required this.id,
    required this.title,
    required this.createAt,
    required this.content,
    this.location,
    this.deadline,
    this.isDone = false,
  });

  TodoItem copyWith({
    String? id,
    String? title,
    DateTime? createAt,
    DateTime? deadline,
    String? location,
    String? content,
    bool? isDone,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      createAt: createAt ?? this.createAt,
      content: content ?? this.content,
      deadline: deadline ?? this.deadline,
      location: location ?? this.location,
      isDone: isDone ?? this.isDone,
    );
  }
}
