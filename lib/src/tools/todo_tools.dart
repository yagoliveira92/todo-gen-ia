import 'package:firebase_ai/firebase_ai.dart';

/// Ferramenta para pedir confirmação ao usuário através de um diálogo de alerta.
/// A IA deve usar esta ferramenta antes de realizar qualquer ação de criação,
/// edição ou exclusão.
final askConfirmationTool = FunctionDeclaration(
  'askConfirmation',
  '''Aciona um diálogo de alerta para pedir a confirmação do usuário 
  antes de executar uma alteração ou criação de uma tarefa. Use esta ferramenta 
  apenas para fazer uma pergunta de sim ou não ao usuário.
  ''',
  parameters: {
    'question': Schema.string(
      description: '''
          A pergunta a ser exibida para o usuário para confirmar a execução de 
          uma alteração ou criação da tarefa. A resposta a esta pergunta 
          precisa ser "sim" ou "não".''',
    ),
  },
);

/// Ferramenta para criar uma nova nota ou tarefa no aplicativo.
final insertTodoTool = FunctionDeclaration(
  'insertTodo',
  'Cria uma nova nota ou tarefa no aplicativo.',
  parameters: {
    'title': Schema.string(
      description: 'O título principal e conciso da tarefa.',
    ),
    'content': Schema.string(
      description:
          'Detalhes adicionais, como locais, descrições ou subtarefas.',
      nullable: true,
    ),
    'deadline': Schema.string(
      description:
          'A data e hora final para a tarefa, no formato ISO 8601 (YYYY-MM-DDTHH:MM:SS).',
      nullable: true,
    ),
    'reminderAt': Schema.string(
      description:
          'A data e hora para notificar o usuário sobre a tarefa, no formato ISO 8601.',
      nullable: true,
    ),
  },
);

/// Ferramenta para remover uma nota ou tarefa existente.
/// A IA deve primeiro confirmar com o usuário usando a ferramenta 'askConfirmation'.
final removeTodoTool = FunctionDeclaration(
  'removeTodo',
  'Remove uma nota ou tarefa existente. O usuário deve especificar qual nota remover.',
  parameters: {
    'id': Schema.string(
      description:
          'O ID único da nota a ser removida. É a forma mais precisa de identificar a nota.',
      nullable: true,
    ),
    'title': Schema.string(
      description:
          'O título da nota a ser removida. Usado para identificar a nota caso o ID não seja conhecido.',
    ),
  },
);

/// Ferramenta para modificar uma nota ou tarefa existente.
/// A IA deve especificar qual nota editar e quais campos devem ser alterados.
final editTodoTool = FunctionDeclaration(
  'editTodo',
  'Modifica uma nota ou tarefa existente. Apenas os campos fornecidos serão alterados.',
  parameters: {
    'id': Schema.string(
      description:
          'O ID único da nota a ser editada, para uma identificação precisa.',
      nullable: true,
    ),
    'originalTitle': Schema.string(
      description:
          'O título da nota original que precisa ser editada, para identificação caso o ID não seja conhecido.',
    ),
    'newTitle': Schema.string(
      description: 'O novo título para a nota.',
      nullable: true,
    ),
    'newContent': Schema.string(
      description:
          'O novo conteúdo para a nota. Se fornecido, substitui completamente o conteúdo antigo.',
      nullable: true,
    ),
    'newDeadline': Schema.string(
      description:
          'A nova data e hora final para a tarefa, no formato ISO 8601.',
      nullable: true,
    ),
    'location': Schema.string(
      description:
          'A localização onde deverá ser executada, caso informado pelo usuário',
      nullable: true,
    ),
  },
);
