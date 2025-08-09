import 'package:flutter/foundation.dart';
import 'package:todo_genia/src/models/todo_model.dart'; // Certifique-se que seu TodoItem tem um `copyWith`

class TodoViewModel extends ChangeNotifier {
  // A lista de tarefas permanece a mesma
  final List<TodoItem> _todos = [];
  List<TodoItem> get todos => List.unmodifiable(_todos);

  TodoViewModel() {
    _initializeDefaultTodos();
  }

  void _initializeDefaultTodos() {
    if (_todos.isEmpty) {
      _addInitialTodo("Comprar leite");
      _addInitialTodo("Fazer exercícios");
      _addInitialTodo("Estudar Flutter com o AppAgent");
    }
  }

  void _addInitialTodo(String title) {
    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString() + title,
      title: title,
      createAt: DateTime.now(),
      content: "",
    );
    _todos.add(newTodo);
  }

  // --- MÉTODOS PÚBLICOS PARA SEREM USADOS PELO AppAgent ---

  /// Adiciona uma nova tarefa à lista.
  /// Corresponde à ferramenta `insertTodoTool`.
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

      // Converte as strings de data para DateTime, se existirem
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
      notifyListeners(); // Notifica a UI diretamente
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
        notifyListeners(); // Notifica a UI diretamente
      } else {
        throw Exception("Tarefa com título '$title' não encontrada.");
      }
    } catch (e) {
      debugPrint('Erro ao remover tarefa: $e');
      throw Exception("Falha ao remover tarefa: ${e.toString()}");
    }
  }

  /// Edita uma tarefa existente.
  /// Corresponde à ferramenta `editTodoTool`.
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
        notifyListeners(); // Notifica a UI diretamente
      } else {
        throw Exception("Tarefa com título '$originalTitle' não encontrada.");
      }
    } catch (e) {
      debugPrint('Erro ao editar tarefa: $e');
      throw Exception("Falha ao editar tarefa: ${e.toString()}");
    }
  }

  /// Alterna o status de 'concluído' de uma tarefa. Pode ser chamado pela UI.
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
    // A limpeza agora é muito mais simples
    super.dispose();
  }
}
