# 🎯 VidaPlus - Habit Tracker Offline

Um aplicativo moderno de rastreamento de hábitos completamente offline, construído com Flutter e Clean Architecture.

## ✨ **Características Principais**

### 🔒 **100% Offline**
- ✅ Todos os dados armazenados localmente com Hive
- ✅ Funciona sem internet
- ✅ Privacidade total dos seus dados
- ✅ Login como convidado ou com Google

### 🎨 **Interface Moderna**
- ✅ Design Material 3 com glassmorphism
- ✅ Animações 3D impressionantes
- ✅ Tema claro/escuro automático
- ✅ Gradientes e micro-interações

### 📱 **Funcionalidades Completas**
- ✅ Criação e gestão de hábitos
- ✅ Check-ins diários com animações
- ✅ Progresso visual com gráficos
- ✅ Notificações personalizadas
- ✅ Histórico detalhado
- ✅ Perfil com foto personalizada

## 🏗️ **Arquitetura**

O projeto segue rigorosamente **Clean Architecture**:

```
lib/
├── domain/           # 🎯 Regras de negócio
│   ├── entities/     # Entidades puras
│   ├── repositories/ # Contratos
│   └── usecases/     # Casos de uso
├── data/             # 💾 Camada de dados
│   ├── datasources/  # Fontes locais (Hive)
│   ├── models/       # Modelos com adapters
│   └── repositories_impl/ # Implementações
└── presentation/     # 🎨 Interface
    ├── controllers/  # Estado (Provider)
    └── pages/        # Telas e widgets
```

## 🚀 **Como Executar**

### **Pré-requisitos**
- Flutter 3.8.0+
- Dart 3.0+

### **Instalação**
```bash
# Clone o repositório
git clone https://github.com/seu-usuario/vidaplus.git
cd vidaplus

# Instale as dependências
flutter pub get

# Gere os adapters do Hive
dart run build_runner build

# Execute o app
flutter run
```

### **Para Web**
```bash
flutter run -d chrome
```

## 🛠️ **Tecnologias**

### **Core**
- **Flutter** - Framework multiplataforma
- **Dart** - Linguagem de programação
- **Provider** - Gerenciamento de estado

### **Armazenamento Local**
- **Hive** - Banco de dados NoSQL local
- **SharedPreferences** - Configurações simples
- **Path Provider** - Caminhos do sistema

### **Autenticação**
- **Google Sign In** - Login social
- **Sistema próprio** - Login como convidado

### **Notificações**
- **Flutter Local Notifications** - Lembretes
- **Timezone** - Agendamento por fuso

### **UI/UX**
- **Material 3** - Design system moderno
- **FL Chart** - Gráficos interativos
- **Animações customizadas** - Micro-interações

## 📋 **Funcionalidades**

### **🔐 Autenticação**
- Login com Google (baixa foto automaticamente)
- Login como convidado (avatar padrão)
- Logout seguro com limpeza de dados

### **🎯 Hábitos**
- Criação com nome, frequência e horário
- Edição completa de propriedades
- Exclusão com confirmação
- Check-in com animação 3D
- Histórico detalhado

### **📊 Progresso**
- Gráficos de linha (semanal)
- Gráficos de barra (mensal)
- Estatísticas detalhadas
- Taxa de conclusão

### **👤 Perfil**
- Foto personalizada (galeria/câmera)
- Dados pessoais editáveis
- Configurações de tema
- Configurações de notificação

### **🔔 Notificações**
- Lembretes personalizados por hábito
- Lembrete diário geral
- Controle total pelo usuário
- Agenda inteligente (pula horários passados)

## 🎨 **Design Moderno**

### **Glassmorphism**
- Efeitos de blur e transparência
- Gradientes dinâmicos
- Bordas sutis com opacidade

### **Animações 3D**
- Check-in com rotação e particles
- Logo pulsante na tela de login
- Transições suaves entre estados
- Micro-interações responsivas

### **Material 3**
- Cores dinâmicas do sistema
- Typography moderna (Inter)
- Components atualizados
- Dark mode automático

## 🧪 **Testes**

```bash
# Executar todos os testes
flutter test

# Testes específicos
flutter test test/auth_controller_test.dart
flutter test test/widget_test.dart
```

## 📱 **Plataformas Suportadas**

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🤝 **Contribuindo**

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 **Licença**

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🎯 **Roadmap**

- [ ] Backup/restore de dados
- [ ] Sincronização entre dispositivos
- [ ] Widgets para tela inicial
- [ ] Integração com Apple Health/Google Fit
- [ ] Gamificação com conquistas
- [ ] Relatórios avançados
- [ ] Modo família/compartilhado

---

**Desenvolvido com ❤️ usando Flutter e Clean Architecture** 