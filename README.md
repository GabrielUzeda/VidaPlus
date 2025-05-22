# 🌟 VidaPlus - Aplicativo de Hábitos Saudáveis

**VidaPlus** é um aplicativo Flutter para acompanhamento de hábitos saudáveis com foco na qualidade de vida. Desenvolvido seguindo **Clean Architecture** e princípios **SOLID**.

## 📱 Sobre o Projeto

O VidaPlus ajuda usuários a:
- 📅 Criar e gerenciar hábitos saudáveis
- ✅ Fazer check-ins diários
- 📊 Visualizar progresso com gráficos
- 🎯 Definir frequências e horários recomendados
- 👤 Gerenciar perfil com foto
- 📈 Acompanhar histórico detalhado

## 🏗️ Arquitetura

### Clean Architecture

O projeto segue rigorosamente a **Clean Architecture** com separação em camadas:

```
lib/
├── domain/           # 🎯 Regras de negócio
│   ├── entities/     # Entidades do domínio
│   ├── repositories/ # Contratos dos repositórios
│   └── usecases/     # Casos de uso da aplicação
├── data/             # 💾 Camada de dados
│   ├── datasources/  # Fontes de dados (Firebase)
│   ├── models/       # Modelos de dados
│   └── repositories_impl/ # Implementações dos repositórios
└── presentation/     # 🎨 Camada de apresentação
    ├── controllers/  # Controllers (Provider)
    └── pages/        # Telas e widgets
```

### Princípios SOLID Aplicados

1. **Single Responsibility Principle (SRP)**: Cada classe tem uma única responsabilidade
   - `HabitController` apenas gerencia estado dos hábitos
   - `FirebaseAuthDatasource` apenas autentica usuários
   - Cada Use Case resolve um problema específico

2. **Open/Closed Principle (OCP)**: Aberto para extensão, fechado para modificação
   - Interfaces como `HabitRepository` permitem novas implementações
   - `AuthRepository` pode ter implementações diferentes (Firebase, local, etc.)

3. **Liskov Substitution Principle (LSP)**: Subtipos substituíveis
   - Qualquer implementação de `HabitRepository` pode ser usada
   - Mock objects para testes seguem as mesmas interfaces

4. **Interface Segregation Principle (ISP)**: Interfaces específicas
   - `HabitRepository` e `AuthRepository` são separados
   - Cada datasource tem interface específica para sua responsabilidade

5. **Dependency Inversion Principle (DIP)**: Dependa de abstrações
   - Controllers dependem de Use Cases (abstrações)
   - Use Cases dependem de Repositories (interfaces)
   - Implementações concretas são injetadas

## 🚀 Configuração e Instalação

### Pré-requisitos

- Flutter SDK (≥ 3.0.0)
- Dart SDK (≥ 3.0.0)
- Node.js (para Firebase CLI)
- Firebase CLI

### Instalação

1. **Clone o repositório:**
```bash
git clone https://github.com/seu-usuario/vidaplus.git
cd VidaPlus
```

2. **Instale dependências:**
```bash
flutter pub get
```

3. **Configure Firebase CLI:**
```bash
npm install -g firebase-tools
firebase --version  # Verificar instalação
```

## 🔥 Firebase Local (Desenvolvimento)

### Configuração Local

Este projeto usa **emuladores Firebase locais** para desenvolvimento, sem necessidade de projeto real ou login.

### Iniciar Emuladores

**Opção 1 - Script automático:**
```bash
./start_emulators.sh
```

**Opção 2 - Comando direto:**
```bash
firebase emulators:start --only auth,firestore --project=demo-vidaplus
```

**Opção 3 - Sem login Firebase:**
```bash
export FIREBASE_CONFIG='{"projectId":"demo-vidaplus","storageBucket":"demo-vidaplus.appspot.com"}'
firebase emulators:start --only auth,firestore
```

### URLs dos Emuladores
- **Firebase Auth**: http://localhost:9099
- **Firestore**: http://localhost:8080
- **Interface Web**: http://localhost:4000

### Executar o App

```bash
# Para web
flutter run -d chrome --web-renderer html

# Para mobile (emulador)
flutter run

# Build para produção web
flutter build web --source-maps
```

## 🧪 Testes

### Executar Testes

```bash
# Todos os testes
flutter test

# Testes com cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Estrutura de Testes

- **Unit Tests**: Testam Use Cases e Models isoladamente
- **Widget Tests**: Testam comportamento de widgets específicos
- **Mocks**: Simulam dependências Firebase para testes consistentes

Exemplo de teste:
```dart
test('deve retornar lista de hábitos do usuário', () async {
  // Arrange
  when(() => mockRepository.getUserHabits(any()))
      .thenAnswer((_) async => [habit1, habit2]);

  // Act
  final result = await usecase('user123');

  // Assert
  expect(result, [habit1, habit2]);
  verify(() => mockRepository.getUserHabits('user123')).called(1);
});
```

## 📊 Funcionalidades Implementadas

### ✅ Autenticação
- Login/Registro com email e senha
- Validação de formulários
- Mensagens de erro amigáveis
- Logout seguro

### ✅ Gestão de Hábitos
- Criar hábitos com frequência (diária/semanal)
- Definir horários recomendados
- Check-ins diários com timestamp
- Editar e excluir hábitos

### ✅ Visualização de Progresso
- Dashboard com resumo do dia
- Gráficos de linha (progresso semanal)
- Gráficos de barras (estatísticas mensais)
- Picker de mês para histórico

### ✅ Perfil do Usuário
- Upload de foto de perfil (câmera/galeria)
- Edição de nome e dados
- Estatísticas pessoais
- Modo escuro/claro

### ✅ Interface
- Design moderno e responsivo
- Textos em português brasileiro
- Notificações locais
- Navegação intuitiva

## 🔧 Solução de Problemas

### Erro: POST http://localhost:9099 400 Bad Request

**Diagnóstico**: Emulador Firebase Auth não está funcionando.

**Soluções:**

1. **Verificar processos:**
```bash
ps aux | grep firebase
lsof -i :9099  # Auth emulator
lsof -i :8080  # Firestore emulator
```

2. **Parar processos anteriores:**
```bash
pkill -f firebase
# ou
sudo kill $(sudo lsof -t -i:9099)
sudo kill $(sudo lsof -t -i:8080)
```

3. **Reiniciar emuladores:**
```bash
./start_emulators.sh
```

4. **Verificar funcionamento:**
```bash
curl http://localhost:9099
curl http://localhost:8080
```

### Erro: Port already in use

```bash
# Verificar qual processo está usando a porta
sudo lsof -i :9099

# Matar processo específico
sudo kill -9 <PID>
```

### Erro: Firebase CLI não encontrado

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Verificar versão
firebase --version
```

### Problemas de CORS no navegador

```bash
flutter run -d chrome --web-renderer html
```

### Teste Rápido da Configuração

Execute este script para testar tudo:

```bash
#!/bin/bash
echo "🧪 Testando configuração Firebase..."

# 1. Verificar Firebase CLI
firebase --version && echo "✅ Firebase CLI OK" || echo "❌ Firebase CLI não encontrado"

# 2. Parar processos
pkill -f firebase
echo "🛑 Processos anteriores finalizados"

# 3. Iniciar emuladores em background
firebase emulators:start --only auth,firestore --project=demo-vidaplus &
echo "🚀 Emuladores iniciando..."

# 4. Aguardar início
sleep 10

# 5. Testar conexões
curl -s http://localhost:9099 > /dev/null && echo "✅ Auth emulator OK" || echo "❌ Auth emulator falhou"
curl -s http://localhost:8080 > /dev/null && echo "✅ Firestore emulator OK" || echo "❌ Firestore emulator falhou"

echo "🏁 Teste concluído!"
echo "📱 Agora execute: flutter run -d chrome"
```

## 🌐 Deploy para Produção

### Firebase Hosting

O projeto está configurado para deploy no Firebase Hosting:

```bash
# Build da aplicação
flutter build web --release

# Deploy para Firebase
firebase deploy --only hosting
```

### Configuração Real do Firebase

Para ambiente de produção, configure um projeto real:

```bash
# Configurar projeto Firebase
flutterfire configure

# Substituir valores dummy em firebase_options.dart
# Atualizar regras de segurança em firestore.rules
```

## 📁 Estrutura de Dados

### Firestore Collections

```
users/
  {userId}/
    - id: string
    - email: string
    - name: string
    - profileImageUrl?: string
    - createdAt: timestamp
    - updatedAt: timestamp

habits/
  {habitId}/
    - id: string
    - userId: string
    - name: string
    - description: string
    - frequency: 'daily' | 'weekly'
    - recommendedTimes: string[]
    - isActive: boolean
    - createdAt: timestamp
    - updatedAt: timestamp

checkins/
  {checkinId}/
    - id: string
    - habitId: string
    - userId: string
    - date: string (YYYY-MM-DD)
    - timestamp: timestamp
    - createdAt: timestamp
```

## 📦 Dependências Principais

```yaml
dependencies:
  flutter: ^3.0.0
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  provider: ^6.1.1
  fl_chart: ^0.65.0
  image_picker: ^1.0.4
  flutter_local_notifications: ^16.1.0
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test: ^3.0.0
  mocktail: ^1.0.1
  flutter_lints: ^3.0.0
```

## 🎯 Próximos Passos

- [ ] Implementar sincronização offline
- [ ] Adicionar gamificação (pontos, conquistas)
- [ ] Integrar com HealthKit/Google Fit
- [ ] Adicionar lembretes personalizáveis
- [ ] Implementar compartilhamento social
- [ ] Adicionar metas mensais/anuais

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👥 Equipe

- **Desenvolvedor Principal**: [Seu Nome]
- **Arquitetura**: Clean Architecture + SOLID
- **Framework**: Flutter 3.x
- **Backend**: Firebase (Auth + Firestore)

## 📞 Suporte

Para problemas ou dúvidas:

1. Verifique a seção de [Solução de Problemas](#-solução-de-problemas)
2. Consulte os logs: `firestore-debug.log`
3. Abra uma issue no repositório
4. Entre em contato: [seu-email@exemplo.com]

---

**VidaPlus** - Transformando hábitos em estilo de vida! 🌟
