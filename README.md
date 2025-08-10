# ToDo GenIA: Organizador Mágico

`ToDo GenIA` é um projeto de aplicativo de lista de tarefas que utiliza o poder da Inteligência Artificial generativa para criar, gerir e organizar as suas tarefas de forma inteligente e intuitiva.

Com uma interface limpa e foco na eficiência, o "Organizador Mágico" permite que você adicione, edite e remova tarefas usando linguagem natural, deixando que a IA cuide dos detalhes.

## Plataformas Suportadas

O projeto está configurado para ser executado nas seguintes plataformas:

## ✨ Funcionalidades

* **Criação Inteligente de Tarefas**: Adicione tarefas usando linguagem natural, como "Lembrar de comprar pão amanhã às 8h". A IA irá extrair o título, detalhes e prazos automaticamente.
* **Gerenciamento de Tarefas por IA**: Edite e remova tarefas também com comandos em linguagem natural.
* **Confirmação de Ações**: Para evitar erros, a IA sempre pedirá a sua confirmação antes de realizar qualquer alteração importante, como adicionar, editar ou remover uma tarefa.
* **Interface Limpa e Intuitiva**: Visualize suas tarefas em uma lista clara e organizada. Marque tarefas como concluídas e veja os detalhes importantes, como prazos e conteúdo adicional.
* **Definição de Prazos e Lembretes**: A IA é capaz de interpretar datas e horas relativas ("amanhã", "próxima sexta") e convertê-las para formatos absolutos para definir prazos e lembretes.

## 🚀 Começando

Siga estas instruções para obter uma cópia do projeto e executá-lo em sua máquina local para desenvolvimento e testes.

### Pré-requisitos

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão `^3.8.1` ou superior)
* Um editor de código como [VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio)
* Configuração do [Firebase](https://firebase.google.com/) para seu projeto (o projeto já inclui os arquivos de configuração `google-services.json` para Android e `GoogleService-Info.plist` para iOS).

### Instalação

1.  **Clone o repositório:**

    ```sh
    git clone https://github.com/yagoliveira92/todo-gen-ia.git
    cd todo-gen-ia
    ```

2.  **Instale as dependências do Flutter:**

    ```sh
    flutter pub get
    ```

3.  **Execute o aplicativo:**

    ```sh
    flutter run
    ```

    Escolha o dispositivo desejado (emulador Android, simulador iOS, Chrome para Web ou a sua máquina Linux).

## 🛠️ Tecnologias Utilizadas

* **[Flutter](https://flutter.dev/)**: Framework de UI para criar aplicativos nativos compilados para múltiplas plataformas a partir de uma única base de código.
* **[Firebase AI](https://firebase.google.com/docs/ai)**: Integração com modelos de IA generativa do Google (Gemini) para alimentar a inteligência do aplicativo.
* **[Provider](https://pub.dev/packages/provider)**: Para gerenciamento de estado de forma simples e eficiente.
* **[intl](https://pub.dev/packages/intl)**: Para formatação de datas e horas.
* **[Firebase Core](https://pub.dev/packages/firebase_core)**: Para inicializar o Firebase no aplicativo.

## 🤝 Como Contribuir

Contribuições são o que tornam a comunidade de código aberto um lugar incrível para aprender, inspirar e criar. Qualquer contribuição que você fizer será **muito apreciada**.

Se você tiver uma sugestão para melhorar este projeto, por favor, crie um "fork" do repositório e crie um "pull request". Você também pode simplesmente abrir uma "issue" com a tag "enhancement".

1.  Crie um Fork do Projeto
2.  Crie a sua Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Faça o Commit das suas alterações (`git commit -m 'Add some AmazingFeature'`)
4.  Faça o Push para a Branch (`git push origin feature/AmazingFeature`)
5.  Abra um Pull Request

## 📜 Licença

Distribuído sob a licença MIT. Veja `LICENSE` para mais informações.