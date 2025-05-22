# Firebase Local - VidaPlus

## Configuração Local do Firebase

Este projeto está configurado para usar apenas os **emuladores locais** do Firebase, sem necessidade de login ou projeto real no Firebase.

## Como Usar

### 1. Iniciar os Emuladores Firebase

```bash
firebase emulators:start --only auth,firestore
```

Isso vai iniciar:
- **Firebase Auth** na porta `9099`
- **Firestore** na porta `8080`
- **Interface Web** geralmente na porta `4000`

### 2. Executar o App Flutter

```bash
flutter run -d chrome
```

### 3. Testar a Configuração (Opcional)

Execute o script de teste:

```bash
dart test_firebase_local.dart
```

## Configuração Atual

### Emuladores Configurados
- **Auth**: localhost:9099
- **Firestore**: localhost:8080

### Valores Dummy
O arquivo `lib/firebase_options.dart` usa valores dummy que funcionam apenas com emuladores:
- Project ID: `vidaplus`
- API Keys: `demo-api-key-*`
- App IDs: `1:123456789:*:abcdef123456`

### Interface dos Emuladores

Quando os emuladores estão rodando, você pode acessar:
- **Firebase Emulator Suite UI**: http://localhost:4000
- **Auth Emulator**: http://localhost:4000/auth
- **Firestore Emulator**: http://localhost:4000/firestore

## Funcionalidades Disponíveis

### ✅ Funcionando Localmente
- Autenticação de usuários
- Firestore (banco de dados)
- Todas as operações CRUD
- Interface web de administração

### ❌ Não Disponível Localmente
- Storage (arquivos)
- Functions (se não configuradas)
- Hosting
- Analytics

## Comandos Úteis

```bash
# Iniciar apenas Auth
firebase emulators:start --only auth

# Iniciar apenas Firestore
firebase emulators:start --only firestore

# Iniciar todos os emuladores
firebase emulators:start

# Limpar dados dos emuladores
firebase emulators:exec --ui "echo 'Emulators cleared'"

# Ver logs dos emuladores
tail -f firebase-debug.log
```

## Estrutura de Dados

Os dados ficam salvos temporariamente enquanto os emuladores estão rodando. Para persistir dados entre execuções, você pode exportar/importar:

```bash
# Exportar dados
firebase emulators:export ./backup

# Importar dados
firebase emulators:start --import ./backup
```

## Solução de Problemas

### Erro "FirebaseOptions cannot be null"
✅ **Resolvido** - O arquivo `firebase_options.dart` agora tem valores válidos para emuladores.

### Emuladores não conectam
1. Verifique se os emuladores estão rodando: `firebase emulators:start`
2. Verifique as portas no console
3. Reinicie os emuladores se necessário

### Erro de CORS no navegador
Adicione as flags ao executar o Flutter web:
```bash
flutter run -d chrome --web-renderer html
``` 