class TodoItem {
  final String id;
  final String title;
  bool isDone;

  TodoItem({required this.id, required this.title, this.isDone = false});
}
