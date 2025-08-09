import 'package:firebase_ai/firebase_ai.dart';

class ChatService {
  Future<void> sendMessageToAgent(
    String todoRequest,
    ChatSession session,
  ) async {
    final prompt = Content.multi([
      TextPart('''
      Por favor, recomende maneiras para o usuário abordar sua solicitação de tarefas.
      SEMPRE responda usando a Ferramenta de Confirmação de Pergunta para mostrar um alerta
      e peça a confirmação do usuário antes de fazer uma alteração.
            '''),
      TextPart('Esta é a tarefa solicitada pelo usuário: $todoRequest'),
    ]);
    final response = await session.sendMessage(prompt);
    if (response.functionCalls.isNotEmpty) {
      return checkFunctionCall(response.functionCalls);
    }
    throw Exception('No function calls found in the response.');
  }

  Future<void> checkFunctionCall(Iterable<FunctionCall> functionCalls) async {
    for (final functionCall in functionCalls) {
      switch (functionCall.name) {
        case 'askConfirmation':
          print('Ask Confirmation');
        case 'insertTodoTool':
          print('Insert Todo');
        case 'removeTodoTool':
          print('Remove Todo');
        case 'editTodoTool':
          print('Edit Todo');
        default:
          throw Exception('Unknown function call: ${functionCall.name}');
      }
      return;
    }
  }
}
