import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_genia/src/agent/app_agent.dart';
import 'package:todo_genia/src/models/todo_model.dart'; // Certifique-se que seu TodoItem tem um `copyWith`

class TodoViewModel extends ChangeNotifier {
  final List<TodoItem> _todos = [];
  List<TodoItem> get todos => List.unmodifiable(_todos);

  final AppAgent _appAgent = AppAgent();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TodoViewModel() {
    _initializeDefaultTodos();
    _appAgent.initialize();
  }

  void _initializeDefaultTodos() {
    if (_todos.isEmpty) {
      _addInitialTodo(
        "Comprar leite",
        "Integral, sem lactose",
        "Mercado",
        DateTime.now().add(Duration(days: 1)),
      );
      _addInitialTodo(
        "Fazer exercícios",
        "30 minutos de cardio",
        "Academia",
        DateTime.now().add(Duration(days: 2)),
      );
      _addInitialTodo(
        "Estudar Flutter com o AppAgent",
        "Utilizar o plano de estudos da Alura",
        "Alura",
        DateTime.now().add(Duration(days: 3)),
      );
    }
  }

  void _addInitialTodo(
    String title,
    String content,
    String location,
    DateTime deadline,
  ) {
    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString() + title,
      title: title,
      createAt: DateTime.now(),
      content: content,
      location: location,
      deadline: deadline,
      isDone: false,
    );
    _todos.add(newTodo);
  }

  Future<void> processUserRequest(BuildContext context, String request) async {
    _setLoading(true);
    try {
      await _appAgent.sendMessageToAgent(request, context);
    } catch (e) {
      debugPrint("Erro no processUserRequest do ViewModel: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocorreu um erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> addTodo({
    required String title,
    String? content,
    String? deadline, // Strings vêm direto da IA
    String? reminderAt,
  }) async {
    try {
      if (title.isEmpty) {
        throw Exception("O título não pode estar vazio.");
      }

      final deadlineDate = deadline != null
          ? DateTime.tryParse(deadline)
          : null;
      final reminderDate = reminderAt != null
          ? DateTime.tryParse(reminderAt)
          : null;

      final newTodo = TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content ?? '',
        createAt: DateTime.now(),
        deadline: deadlineDate,
      );

      _todos.add(newTodo);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar tarefa: $e');
      // Lança a exceção para que o chamador (AppAgent) possa lidar com ela
      throw Exception("Falha ao adicionar tarefa: ${e.toString()}");
    }
  }

  /// Remove uma tarefa da lista.
  /// Corresponde à ferramenta `removeTodoTool`.
  Future<void> removeTodo({String? id, required String title}) async {
    try {
      int removedIndex = -1;
      if (id != null && id.isNotEmpty) {
        removedIndex = _todos.indexWhere((todo) => todo.id == id);
      } else {
        removedIndex = _todos.indexWhere(
          (todo) => todo.title.toLowerCase() == title.toLowerCase(),
        );
      }

      if (removedIndex != -1) {
        _todos.removeAt(removedIndex);
        notifyListeners();
      } else {
        throw Exception("Tarefa com título '$title' não encontrada.");
      }
    } catch (e) {
      debugPrint('Erro ao remover tarefa: $e');
      throw Exception("Falha ao remover tarefa: ${e.toString()}");
    }
  }

  Future<void> editTodo({
    String? id,
    required String originalTitle,
    String? newTitle,
    String? newContent,
    String? newDeadline,
    bool? isDone,
    String? newLocation,
  }) async {
    try {
      int todoIndex = -1;
      if (id != null && id.isNotEmpty) {
        todoIndex = _todos.indexWhere((todo) => todo.id == id);
      } else {
        todoIndex = _todos.indexWhere(
          (todo) => todo.title.toLowerCase() == originalTitle.toLowerCase(),
        );
      }

      if (todoIndex != -1) {
        final originalTodo = _todos[todoIndex];

        // Usando o método `copyWith` no seu modelo (altamente recomendado)
        final updatedTodo = originalTodo.copyWith(
          title:
              newTitle, // Se newTitle for nulo, o copyWith manterá o original
          content: newContent,
          deadline: newDeadline != null
              ? DateTime.tryParse(newDeadline)
              : originalTodo.deadline,
          isDone: isDone,
          location: newLocation,
        );

        _todos[todoIndex] = updatedTodo;
        notifyListeners();
      } else {
        throw Exception("Tarefa com título '$originalTitle' não encontrada.");
      }
    } catch (e) {
      debugPrint('Erro ao editar tarefa: $e');
      throw Exception("Falha ao editar tarefa: ${e.toString()}");
    }
  }

  Future<void> toggleTodoStatus(String id) async {
    try {
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex].isDone = !_todos[todoIndex].isDone;
        notifyListeners();
      } else {
        throw Exception("Tarefa não encontrada.");
      }
    } catch (e) {
      debugPrint('Erro ao alternar status da tarefa: $e');
      throw Exception("Falha ao alternar status: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
