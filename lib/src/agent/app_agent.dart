import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:todo_genia/src/tools/todo_tools.dart';

class AppAgent {
  GenerativeModel initChat(String databaseSchema) {
    String baseFormat = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ssZ",
    ).format(DateTime.now());
    final systemInstructionText =
        '''
# Persona e Objetivo
Você é um assistente inteligente ultra-eficiente, integrado a um aplicativo de organização chamado "Organizador Mágico". Sua principal função é interpretar solicitações do usuário em linguagem natural e traduzi-las em uma chamada de função estruturada para criar uma nova nota ou tarefa. Você deve ser preciso, rápido e nunca fazer perguntas de volta; sua única saída deve ser a chamada da função.

# Ferramenta Disponível
Você tem acesso a uma única ferramenta (função) chamada `createTask`.

## Definição da ferramenta `createTask`:
- `createTask(title: string, content: string | null, deadline: string | null, reminderAt: string | null)`

### Parâmetros da Ferramenta:
- `title` (string, obrigatório): O título principal e conciso da tarefa. A ação principal que o usuário quer lembrar.
- `content` (string, opcional): Detalhes adicionais, como locais, pessoas, links, descrições ou subtarefas. Se não houver detalhes extras, este campo deve ser `null`.
- `deadline` (string, opcional): A data e hora exatas em que a tarefa DEVE ser concluída, no formato ISO 8601 (`YYYY-MM-DDTHH:MM:SS`).
- `reminderAt` (string, opcional): A data e hora exatas em que o usuário deve ser ATIVAMENTE NOTIFICADO sobre a tarefa, também no formato ISO 8601 (`YYYY-MM-DDTHH:MM:SS`).

# Regras e Diretrizes de Processamento
1.  **Extração de Entidades**: Identifique o `title`, `content`, `deadline` e `reminderAt` a partir da solicitação do usuário.
2.  **Processamento de Data e Hora**:
    - Você DEVE converter datas e horas relativas (como "amanhã", "hoje à noite", "próxima sexta", "daqui a duas horas") em um formato de data e hora absoluto e completo (ISO 8601).
    - Utilize o **Contexto Atual** fornecido abaixo para fazer essa conversão com precisão.
    - Se o usuário especificar apenas a data, assuma um horário padrão para o `deadline`, como o final do dia (23:59:59).
    - Se o usuário especificar apenas a hora, assuma a data de hoje, ou de amanhã se a hora já passou.
3.  **Distinção entre `deadline` e `reminderAt`**:
    - Se o usuário disser "Lembrar de...", "Me lembre...", ou "Agendar um lembrete para...", preencha o campo `reminderAt`.
    - Se o usuário disser "entregar até...", "prazo final é...", ou "fazer até...", preencha o campo `deadline`.
    - Se a solicitação for ambígua, como "Tarefa X para as 15h de amanhã", é seguro preencher **ambos**, `deadline` e `reminderAt`, com o mesmo valor, pois a intenção é executar a tarefa naquele momento.
4.  **Título vs. Conteúdo**: O `title` deve ser a ação principal ("Ir ao barbeiro", "Comprar leite", "Entregar relatório"). Detalhes como o nome do lugar, endereço ou informações adicionais devem ir para o `content` ("na Garcia Barber", "integral, sem lactose", "Relatório financeiro Q3").
5.  **Campos Nulos**: Se uma informação não for fornecida (sem detalhes de conteúdo, sem data), o campo correspondente na chamada da função DEVE ser `null`.

# Contexto Atual (A ser injetado dinamicamente pelo seu app)
- **Data e Hora Atuais**: $baseFormat
    ''';
    final geminiModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.text(systemInstructionText),
      tools: [
        Tool.functionDeclarations([
          askConfirmationTool,
          insertTodoTool,
          removeTodoTool,
          editTodoTool,
        ]),
      ],
    );

    return geminiModel;
  }

  late ChatSession chat;

  // 2. LÓGICA DE CONFIRMAÇÃO (REUTILIZADA E TRADUZIDA)
  // Mostra um diálogo de confirmação para o usuário.
  Future<bool> askConfirmation(BuildContext context, String question) async {
    var response = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Organizador Mágico'),
          content: Text(question),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Sim, por favor'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Não'),
            ),
          ],
        );
      },
    );
    return response ?? false;
  }

  // Chamado quando a IA quer usar a ferramenta 'askConfirmation'.
  Future<GenerateContentResponse?> askConfirmationCall(
    BuildContext context,
    FunctionCall functionCall,
  ) async {
    var question = functionCall.args['question']! as String;

    if (context.mounted) {
      final functionResult = await askConfirmation(context, question);

      // Envia a resposta do usuário ("sim" ou "não") de volta para a IA
      final response = await chat.sendMessage(
        Content.text(functionResult ? 'Sim, pode fazer.' : 'Não, cancele.'),
      );

      return response;
    }
    return null;
  }

  // 3. O ROTEADOR PRINCIPAL DE FUNÇÕES
  // Verifica e direciona as chamadas de função da IA para os métodos corretos.
  void checkFunctionCalls(
    BuildContext context,
    Iterable<FunctionCall> functionCalls,
  ) async {
    for (var functionCall in functionCalls) {
      debugPrint('IA chamou a função: ${functionCall.name}');
      GenerateContentResponse? response;
      switch (functionCall.name) {
        case 'askConfirmation':
          response = await askConfirmationCall(context, functionCall);
          break;
        case 'insertTodo':
          insertTodoCall(context, functionCall);
          break;
        case 'removeTodo':
          removeTodoCall(context, functionCall);
          break;
        case 'editTodo':
          editTodoCall(context, functionCall);
          break;
        default:
          throw UnimplementedError(
            'Função não declarada para o modelo: ${functionCall.name}',
          );
      }

      // Se a resposta de uma função contiver outra chamada (encadeamento), processa-a.
      if (response != null &&
          response.functionCalls.isNotEmpty &&
          context.mounted) {
        checkFunctionCalls(context, response.functionCalls);
      }
    }
    return;
  }

  // 4. IMPLEMENTAÇÃO DAS FUNÇÕES DE NOTAS
  // Executa a ação APÓS a confirmação do usuário.
  void insertTodoCall(BuildContext context, FunctionCall functionCall) {
    final args = functionCall.args;
    final title = args['title'] as String;
    // ... extraia outros argumentos como content, deadline, etc.

    // AQUI você chamaria sua lógica de estado para adicionar a nota
    // Ex: context.read<AppState>().addNote(title: title, ...);

    debugPrint('EXECUTANDO: Inserindo a tarefa "$title"');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarefa "$title" criada com sucesso!')),
    );
  }

  void removeTodoCall(BuildContext context, FunctionCall functionCall) {
    final args = functionCall.args;
    final title = args['title'] as String;
    // ... extraia o ID se disponível

    // Lógica de estado para remover a nota
    // Ex: context.read<AppState>().removeNote(title: title);

    debugPrint('EXECUTANDO: Removendo a tarefa "$title"');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Tarefa "$title" removida.')));
  }

  void editTodoCall(BuildContext context, FunctionCall functionCall) {
    final args = functionCall.args;
    final originalTitle = args['originalTitle'] as String;
    final newTitle = args['newTitle'] as String?;
    // ... extraia outros campos a serem alterados

    // Lógica de estado para editar a nota
    // Ex: context.read<AppState>().editNote(originalTitle: originalTitle, ...);

    debugPrint('EXECUTANDO: Editando a tarefa "$originalTitle"');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarefa "$originalTitle" atualizada.')),
    );
  }

  // 5. PONTO DE ENTRADA PRINCIPAL
  // Inicia o processo ao receber o texto do usuário.
  Future<void> sendMessageToAgent(
    String todoRequest,
    BuildContext context,
  ) async {
    final prompt = Content.multi([
      TextPart('''
      Por favor, recomende maneiras para o usuário abordar sua solicitação de tarefas.
      SEMPRE responda usando a Ferramenta de Confirmação de Pergunta para mostrar um alerta
      e peça a confirmação do usuário antes de fazer uma alteração.
            '''),
      TextPart('Esta é a tarefa solicitada pelo usuário: $todoRequest'),
    ]);
    final response = await chat.sendMessage(prompt);
    if (response.functionCalls.isNotEmpty) {
      return checkFunctionCalls(context, response.functionCalls);
    }
    throw Exception('No function calls found in the response.');
  }
}
