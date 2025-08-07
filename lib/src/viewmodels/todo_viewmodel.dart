import 'package:flutter/foundation.dart';
import 'package:todo_genia/src/models/todo_model.dart';
import 'package:todo_genia/src/utils/commands/command.dart';
import 'package:todo_genia/src/utils/result.dart';

class TodoViewModel extends ChangeNotifier {
  // Lista de tarefas (gerenciada internamente)
  final List<TodoItem> _todos = [];
  List<TodoItem> get todos => List.unmodifiable(_todos); // Expor como imutável

  // Comandos
  late Command1<void, String> addTodoCommand;
  late Command1<void, String> toggleTodoStatusCommand;
  // Se você tivesse um comando para carregar todos sem argumentos:
  // late Command0<void> fetchTodosCommand;

  TodoViewModel() {
    addTodoCommand = Command1<void, String>(_addTodo);
    toggleTodoStatusCommand = Command1<void, String>(_toggleTodoStatus);

    // Exemplo: Carregar dados iniciais (você pode ter um comando para isso)
    // Se você tiver dados iniciais para carregar, pode fazê-lo aqui ou
    // expor um comando `fetchTodosCommand` para ser chamado pela View.
    _initializeDefaultTodos();

    // Ouvir mudanças nos comandos para notificar a UI sobre o estado da lista
    // de tarefas, se o resultado do comando implicar uma mudança na lista.
    // Isso é útil se o comando em si não modificar diretamente `_todos`
    // e chamar `notifyListeners()`.
    addTodoCommand.addListener(_onCommandStateChanged);
    toggleTodoStatusCommand.addListener(_onCommandStateChanged);
  }

  void _onCommandStateChanged() {
    // Se um comando completou (com ou sem erro),
    // e esse comando modifica a lista de `_todos`,
    // nós precisamos notificar os ouvintes do ViewModel
    // para que a lista seja reconstruída.
    // O `notifyListeners()` dentro do `_execute` do Command
    // notifica sobre o estado do *comando* (running, error, completed).
    // Este `notifyListeners()` notifica sobre o estado do *ViewModel* (a lista de todos).
    if (addTodoCommand.completed ||
        addTodoCommand.error ||
        toggleTodoStatusCommand.completed ||
        toggleTodoStatusCommand.error) {
      notifyListeners();
    }
  }

  void _initializeDefaultTodos() {
    // Apenas para exemplo, para ter alguns dados.
    // Em um app real, isso viria de um repositório/serviço.
    if (_todos.isEmpty) {
      _addInitialTodo("Comprar leite");
      _addInitialTodo("Fazer exercícios");
      _addInitialTodo("Estudar Flutter com Command Pattern");
    }
  }

  // Método interno para adicionar durante a inicialização, sem usar o Command
  void _addInitialTodo(String title) {
    final newTodo = TodoItem(
      id:
          DateTime.now().millisecondsSinceEpoch.toString() +
          title, // ID mais único
      title: title,
    );
    _todos.add(newTodo);
    // Não precisa de notifyListeners() aqui se chamado no construtor antes da UI ouvir
  }

  // Ação para o comando addTodoCommand
  Future<Result<void>> _addTodo(String title) async {
    try {
      // Simular alguma lógica, talvez uma chamada de API
      // await Future.delayed(Duration(seconds: 1));

      if (title.isEmpty) {
        return Result.error(Exception("O título não pode estar vazio."));
      }

      final newTodo = TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
      );
      _todos.add(newTodo);
      // notifyListeners(); // O _onCommandStateChanged cuidará disso.
      return Result.ok(null); // null para void
    } catch (e) {
      //print('Erro ao adicionar tarefa: $e');
      return Result.error(
        Exception("Falha ao adicionar tarefa: ${e.toString()}"),
      );
    }
  }

  // Ação para o comando toggleTodoStatusCommand
  Future<Result<void>> _toggleTodoStatus(String id) async {
    try {
      // Simular alguma lógica
      // await Future.delayed(Duration(milliseconds: 500));

      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex].isDone = !_todos[todoIndex].isDone;
        // notifyListeners(); // O _onCommandStateChanged cuidará disso.
        return Result.ok(null);
      } else {
        return Result.error(Exception("Tarefa não encontrada."));
      }
    } catch (e) {
      //print('Erro ao alternar status da tarefa: $e');
      return Result.error(
        Exception("Falha ao alternar status: ${e.toString()}"),
      );
    }
  }

  @override
  void dispose() {
    addTodoCommand.removeListener(_onCommandStateChanged);
    toggleTodoStatusCommand.removeListener(_onCommandStateChanged);
    addTodoCommand.dispose(); // Lembre-se de fazer dispose dos Commands
    toggleTodoStatusCommand.dispose();
    super.dispose();
  }
}
