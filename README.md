# Vida+ (Healthy Habits Journal)

Um aplicativo Flutter para gerenciamento de hábitos saudáveis, com foco em acompanhamento diário e análise de progresso.

## Arquitetura e Padrões de Design

Este projeto foi implementado seguindo princípios de Clean Architecture e SOLID, organizando o código em três camadas principais:

### 1. Camada de Domínio (Domain Layer)
* **Entidades**: Representações dos objetos de negócio (User, Habit, CheckIn)
* **Repositórios**: Interfaces que definem operações de dados
* **Casos de Uso**: Lógica de negócio específica da aplicação

### 2. Camada de Dados (Data Layer)
* **Modelos**: Implementações das entidades com serialização/desserialização
* **Fontes de Dados**: Acesso a APIs externas (Firebase)
* **Implementações de Repositórios**: Conectam o domínio às fontes de dados

### 3. Camada de Apresentação (Presentation Layer)
* **Controladores**: Gerenciamento de estado com ChangeNotifier
* **Páginas**: Telas da interface do usuário
* **Widgets**: Componentes reutilizáveis de UI

## Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento cross-platform
- **Firebase Auth**: Autenticação de usuários
- **Cloud Firestore**: Banco de dados NoSQL para armazenamento de hábitos e check-ins
- **Firebase Storage**: Armazenamento de imagens de perfil
- **Provider**: Gerenciamento de estado
- **GetIt**: Injeção de dependência

## Princípios SOLID Aplicados

1. **Princípio de Responsabilidade Única (SRP)**: 
   - Cada classe tem uma única responsabilidade (ex: UserRepository gerencia apenas dados de usuários)

2. **Princípio Aberto-Fechado (OCP)**:
   - Extensão através de abstrações (interfaces de repositórios)

3. **Princípio da Substituição de Liskov (LSP)**:
   - Models podem ser usados onde as entidades são esperadas

4. **Princípio da Segregação de Interface (ISP)**:
   - Interfaces específicas divididas por funcionalidade (AuthRepository, HabitRepository, etc.)

5. **Princípio da Inversão de Dependência (DIP)**:
   - Dependências externas como Firebase são abstraídas através de interfaces

## Como Executar o Projeto

### Pré-requisitos
- Flutter SDK (versão 3.0 ou superior)
- Dart SDK (versão 3.0 ou superior)
- Firebase CLI

### Configuração do Firebase
1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicione um aplicativo Flutter ao projeto
3. Baixe o arquivo `google-services.json` e adicione à pasta `android/app`
4. Baixe o arquivo `GoogleService-Info.plist` e adicione à pasta `ios/Runner`
5. Habilite Firebase Authentication, Firestore e Storage no console

### Instruções de Build
1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/vida_plus.git
cd vida_plus
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
flutter run
```

## Funcionalidades

- **Autenticação**: Login e cadastro com email/senha
- **Gerenciamento de Hábitos**: Criação, edição e exclusão
- **Check-in Diário**: Marcar hábitos como concluídos
- **Dashboard**: Visualização do progresso diário
- **Histórico**: Análise de desempenho ao longo do tempo
- **Perfil de Usuário**: Edição de informações e foto

## Testes

O projeto inclui:
- Testes unitários para entidades e casos de uso
- Testes de controladores (ChangeNotifier)

Para executar os testes:
```bash
flutter test
```

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo LICENSE para mais detalhes. 