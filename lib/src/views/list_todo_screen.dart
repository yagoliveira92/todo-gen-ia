// views/list_todo_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/todo_viewmodel.dart'; // Ajuste o caminho
// Importe seu Command se precisar verificar o estado do comando diretamente
// import 'package:todo_genia/src/utils/commands/command.dart';

class ListTodoScreen extends StatefulWidget {
  const ListTodoScreen({Key? key}) : super(key: key);

  @override
  _ListTodoScreenState createState() => _ListTodoScreenState();
}

class _ListTodoScreenState extends State<ListTodoScreen> {
  // Não precisamos mais do initState para adicionar todos, o ViewModel cuida disso.

  @override
  Widget build(BuildContext context) {
    // O Consumer<TodoViewModel> ainda é a forma principal de obter o viewModel
    // e reconstruir quando a lista de todos (ou outras propriedades do viewModel) mudam.
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Tarefas (Command)')),
      body: Consumer<TodoViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.todos.isEmpty && !viewModel.addTodoCommand.running) {
            // Exemplo de verificação
            return const Center(child: Text('Nenhuma tarefa ainda!'));
          }
          // Você pode querer mostrar um indicador de loading global se
          // um comando importante (como fetchTodos) estiver rodando.
          // if (viewModel.fetchTodosCommand.running) {
          //   return Center(child: CircularProgressIndicator());
          // }

          return ListView.builder(
            itemCount: viewModel.todos.length,
            itemBuilder: (context, index) {
              final todo = viewModel.todos[index];
              // Para o Checkbox, podemos usar o estado do comando para desabilitar
              // enquanto a ação está em progresso, se desejado.
              final isToggleRunning = viewModel.toggleTodoStatusCommand.running;

              return ListTile(
                title: Text(
                  todo.title,
                  style: TextStyle(
                    decoration: todo.isDone ? TextDecoration.lineThrough : null,
                    color: todo.isDone ? Colors.grey : null,
                  ),
                ),
                leading: Checkbox(
                  value: todo.isDone,
                  onChanged: isToggleRunning
                      ? null // Desabilita se o comando estiver rodando
                      : (bool? value) {
                          viewModel.toggleTodoStatusCommand.execute(todo.id).then((
                            _,
                          ) {
                            // O resultado do comando (sucesso/erro) é gerenciado dentro do Command
                            // e o viewModel.toggleTodoStatusCommand.result pode ser inspecionado.
                            // A lista será atualizada pelo listener no ViewModel.
                            if (viewModel.toggleTodoStatusCommand.error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erro ao atualizar tarefa: ${viewModel.toggleTodoStatusCommand.result?.toString() ?? "Erro desconhecido"}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              viewModel.toggleTodoStatusCommand
                                  .clearResult(); // Limpa o resultado
                            }
                          });
                        },
                ),
                // Exemplo de como mostrar um indicador de loading no item
                // se o comando específico para ele estiver rodando (mais complexo de rastrear por item)
                // trailing: viewModel.toggleTodoStatusCommand.running && viewModel.toggleTodoStatusCommand.lastArg == todo.id
                //    ? CircularProgressIndicator()
                //    : null, // Ou seu ícone de deletar, etc.
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Use um `ChangeNotifierProvider.value` ou `Consumer` para o botão
        // se você quiser que ele reaja ao estado `running` do `addTodoCommand`.
        onPressed: () {
          final viewModel = Provider.of<TodoViewModel>(context, listen: false);
          if (viewModel.addTodoCommand.running)
            return; // Evita múltiplos cliques
          _showAddTaskDialog(context, viewModel);
        },
        // Exemplo de como mudar o ícone baseado no estado do comando
        child: Consumer<TodoViewModel>(
          builder: (context, vm, _) {
            return vm.addTodoCommand.running
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : const Icon(Icons.add);
          },
        ),
      ),
    );
  }

  Future<void> _showAddTaskDialog(
    BuildContext context,
    TodoViewModel viewModel,
  ) async {
    final TextEditingController textFieldController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: !viewModel
          .addTodoCommand
          .running, // Não permite fechar se estiver adicionando
      builder: (BuildContext dialogContext) {
        // Use um StatefulWidget dentro do diálogo ou um ValueListenableBuilder
        // se você quiser que o botão "Adicionar" do diálogo também reaja ao estado do comando.
        // Por simplicidade, aqui o botão não será desabilitado dinamicamente no diálogo.
        return AlertDialog(
          title: const Text('Adicionar Nova Tarefa'),
          content: TextField(
            controller: textFieldController,
            decoration: const InputDecoration(hintText: "Título da tarefa"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: viewModel.addTodoCommand.running
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () {
                // Não precisa verificar `running` aqui explicitamente se o botão já faz isso
                // ou se o FAB já previne a abertura do diálogo.
                if (textFieldController.text.isNotEmpty) {
                  viewModel.addTodoCommand.execute(textFieldController.text).then((
                    _,
                  ) {
                    if (viewModel.addTodoCommand.completed) {
                      Navigator.of(dialogContext).pop();
                      // Opcional: Mostrar SnackBar de sucesso
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text('Tarefa adicionada!'), backgroundColor: Colors.green),
                      // );
                    } else if (viewModel.addTodoCommand.error) {
                      // Mostrar erro dentro do diálogo ou fechar e mostrar SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erro ao adicionar: ${viewModel.addTodoCommand.result?.toString() ?? "Erro desconhecido"}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    // Sempre limpe o resultado após o uso para evitar mostrar mensagens antigas
                    viewModel.addTodoCommand.clearResult();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}
