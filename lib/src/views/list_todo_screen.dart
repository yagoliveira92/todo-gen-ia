import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_genia/src/models/todo_model.dart';
import 'package:todo_genia/src/viewmodels/todo_viewmodel.dart';

class ListTodoScreen extends StatelessWidget {
  const ListTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizador Mágico')),
      body: Consumer<TodoViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.todos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Nenhuma tarefa ainda!\nClique no ícone ✨ para adicionar uma.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: viewModel.todos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final todo = viewModel.todos[index];
              return _buildTodoCard(context, todo, viewModel);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final viewModel = context.read<TodoViewModel>();
          if (viewModel.isLoading) return;
          _showAgentBottomSheet(context, viewModel);
        },
        child: Consumer<TodoViewModel>(
          builder: (context, vm, _) {
            return vm.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Icon(Icons.auto_awesome);
          },
        ),
      ),
    );
  }

  Widget _buildTodoCard(
    BuildContext context,
    TodoItem todo,
    TodoViewModel viewModel,
  ) {
    final bool isDone = todo.isDone;
    final Color? textColor = isDone ? Colors.grey : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isDone,
                  onChanged: (bool? value) =>
                      viewModel.toggleTodoStatus(todo.id),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                  onPressed: () {
                    final request = 'Remover a tarefa "${todo.title}"';
                    viewModel.processUserRequest(context, request);
                  },
                ),
              ],
            ),
            // Seção de detalhes (conteúdo, prazo, lembrete)
            if (todo.content.isNotEmpty || todo.deadline != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    if (todo.content.isNotEmpty)
                      _buildDetailRow(
                        Icons.short_text,
                        todo.content,
                        textColor,
                      ),
                    if (todo.deadline != null)
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'Prazo: ${DateFormat('dd/MM/yyyy HH:mm').format(todo.deadline!)}',
                        textColor,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAgentBottomSheet(
    BuildContext context,
    TodoViewModel viewModel,
  ) async {
    final TextEditingController textFieldController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // Permite que o sheet suba com o teclado
      builder: (BuildContext dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'O que você gostaria de fazer?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textFieldController,
                decoration: const InputDecoration(
                  hintText: 'Ex: "Lembrar de comprar pão amanhã às 8h"',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Enviar'),
                onPressed: () {
                  if (textFieldController.text.isNotEmpty) {
                    // Pega o texto e envia para o ViewModel processar
                    viewModel.processUserRequest(
                      context,
                      textFieldController.text,
                    );
                    // Fecha a BottomSheet
                    Navigator.of(dialogContext).pop();
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
