# 🌟 VidaPlus - Aplicativo de Hábitos Saudáveis

**VidaPlus** é um aplicativo Flutter para acompanhamento de hábitos saudáveis com foco na qualidade de vida. Desenvolvido seguindo **Clean Architecture** e princípios **SOLID**.

## 🚀 Como Executar (Início Rápido)

### 1. Pré-requisitos
- Flutter SDK (≥ 3.0.0)
- Node.js para Firebase CLI
- Git

### 2. Instalação
```bash
# Clone o repositório
git clone https://github.com/GabrielUzeda/VidaPlus.git
cd VidaPlus

# Instale dependências
flutter pub get

# Instale Firebase CLI (se não tiver)
npm install -g firebase-tools
```

### 3. Executar o App (Desenvolvimento Local)
```bash
# Inicie os emuladores Firebase
./start_emulators.sh

# Em outro terminal, execute o app
flutter run -d chrome --web-renderer html
```

**Pronto!** O app estará rodando em http://localhost:***XX** (a porta será exibida no terminal)

### 4. Parar os Emuladores
```bash
# Para parar os emuladores quando terminar
pkill -f firebase
```

## 📱 Como Usar o App

### Primeiro Acesso
1. **Registrar conta**: Clique em "Criar conta" na tela inicial
2. **Fazer login**: Use email e senha cadastrados
3. **Permitir notificações**: Aceite as permissões quando solicitado

### Gerenciar Hábitos
1. **Criar hábito**: Clique no botão "+" no dashboard
2. **Configurar**:
   - Nome do hábito (ex: "Beber água")
   - Descrição opcional
   - Frequência: Diária ou Semanal
   - Horários recomendados (opcional)
3. **Check-in diário**: Toque no card do hábito para marcar como concluído
4. **Ver progresso**: Vá para a aba "Progresso" para ver gráficos

### Configurar Perfil
1. **Editar perfil**: Vá para aba "Perfil" → botão "Editar"
2. **Foto de perfil**: Toque na foto para escolher da galeria ou câmera
3. **Configurações**: Ajuste tema, cor do app e notificações

## 📊 Funcionalidades

- ✅ **Autenticação**: Login/registro seguro
- ✅ **Hábitos**: Criar, editar, excluir e fazer check-ins
- ✅ **Progresso**: Gráficos de linha e barras
- ✅ **Perfil**: Foto, dados pessoais, configurações
- ✅ **Notificações**: Lembretes personalizados
- ✅ **Temas**: Modo claro/escuro, cores customizáveis

## 🔧 Solução de Problemas Comuns

### ❌ Erro "Port already in use"
```bash
# Pare todos os processos Firebase
pkill -f firebase

# Ou mate processos específicos das portas
sudo kill $(sudo lsof -t -i:9099)  # Auth
sudo kill $(sudo lsof -t -i:8080)  # Firestore
```

### ❌ Erro "Firebase CLI not found"
```bash
# Instale o Firebase CLI
npm install -g firebase-tools

# Verifique a instalação
firebase --version
```

### ❌ App não conecta aos emuladores
```bash
# Teste se os emuladores estão funcionando
curl http://localhost:9099  # Auth
curl http://localhost:8080  # Firestore

# Se não funcionarem, reinicie:
./start_emulators.sh
```

### ❌ Problemas de CORS no navegador
```bash
# Use o renderer HTML específico
flutter run -d chrome --web-renderer html
```

## 🧪 Testes

```bash
# Executar todos os testes
flutter test

# Testes com cobertura
flutter test --coverage
```

## 🏗️ Arquitetura Técnica

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

1. **Single Responsibility**: Cada classe tem uma única responsabilidade
2. **Open/Closed**: Aberto para extensão, fechado para modificação
3. **Liskov Substitution**: Subtipos substituíveis
4. **Interface Segregation**: Interfaces específicas
5. **Dependency Inversion**: Dependa de abstrações

## 🔥 Firebase Emuladores (Desenvolvimento)

### Por que usar emuladores?
- **Desenvolvimento offline**: Não precisa de conexão com internet
- **Dados locais**: Não interfere com dados de produção
- **Rápido**: Sem latência de rede
- **Grátis**: Sem custos de Firebase

### Configuração dos Emuladores
O projeto está configurado para usar emuladores locais:
- **Auth**: http://localhost:9099
- **Firestore**: http://localhost:8080
- **Interface**: http://localhost:4000

### Script de Inicialização
O arquivo `start_emulators.sh` automatiza toda a configuração:
```bash
#!/bin/bash
export FIREBASE_CONFIG='{"projectId":"demo-vidaplus","storageBucket":"demo-vidaplus.appspot.com"}'
firebase emulators:start --only auth,firestore --project=demo-vidaplus
```

## 📁 Estrutura de Dados (Firestore)

```
users/
  {userId}/
    - id: string
    - email: string
    - name: string
    - profileImageUrl?: string
    - createdAt: timestamp

habits/
  {habitId}/
    - id: string
    - userId: string
    - name: string
    - frequency: 'daily' | 'weekly'
    - recommendedTimes: string[]
    - isActive: boolean

checkins/
  {checkinId}/
    - id: string
    - habitId: string
    - userId: string
    - date: string (YYYY-MM-DD)
    - timestamp: timestamp
```

## 📦 Principais Dependências

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
```

## 🌐 Deploy para Produção

Para deployment em produção:

```bash
# Build para web
flutter build web --release

# Deploy no Firebase Hosting
firebase deploy --only hosting
```

**Nota**: Para produção, configure um projeto Firebase real com `flutterfire configure`

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch: `git checkout -b feature/nova-funcionalidade`
3. Commit: `git commit -am 'Adiciona nova funcionalidade'`
4. Push: `git push origin feature/nova-funcionalidade`
5. Abra um Pull Request

## 👨‍💻 Desenvolvedor

**Gabriel Uzeda**
- 💼 Website: [uzeda.ddns.net](https://uzeda.ddns.net)
- 📧 Email: uzeda.dev@gmail.com

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

## 📞 Suporte

Para problemas ou dúvidas:
- 🐛 Abra uma [issue](https://github.com/GabrielUzeda/VidaPlus/issues)
- 📧 Entre em contato: uzeda.dev@gmail.com
- 🌐 Visite: [uzeda.ddns.net](https://uzeda.ddns.net)

---