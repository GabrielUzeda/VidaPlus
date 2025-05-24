# 🔔 Guia de Solução de Problemas - Notificações do Vida+

## 🎯 Principais Melhorias Implementadas

### 1. **Plugin Atualizado**
- Atualizado `flutter_local_notifications` de `^17.0.0` para `^19.2.1`
- Atualizado `timezone` de `^0.9.4` para `^0.10.1`
- **Corrigido problema de compatibilidade Android**: Atualizado `desugar_jdk_libs` de `2.0.4` para `2.1.4`
- Corrigidos bugs conhecidos em versões anteriores

### 2. **Agendamento Mais Robusto**
- ✅ Cancela notificações antigas antes de criar novas (evita duplicatas)
- ✅ Usa `AndroidScheduleMode.exactAllowWhileIdle` para alarmes exatos
- ✅ Fallback automático para alarmes inexatos se necessário
- ✅ Logs detalhados para facilitar depuração

### 3. **Ferramentas de Depuração**
- 🛠️ Botão "Debug" na página de perfil (modo debug apenas)
- 🛠️ Botão "Reset" para limpar todas as notificações
- 📋 Logs detalhados no console

### 4. **Solicitação Automática de Permissões**
- ✅ **Permissões solicitadas na inicialização**: Quando abrir o app, automaticamente solicita permissões
- ✅ **Diálogos educativos**: Explica por que as permissões são necessárias
- ✅ **Verificação de alarmes exatos**: Alerta se alarmes precisos não estão disponíveis
- ✅ **Logs detalhados**: Console mostra cada etapa do processo de agendamento

## 🚨 Problemas Comuns e Soluções

### **1. Erro de Build Android (desugar_jdk_libs)**
**Erro**: `Dependency ':flutter_local_notifications' requires desugar_jdk_libs version to be 2.1.4 or above`

**Solução**:
1. Abra `android/app/build.gradle.kts`
2. Atualize a linha de dependências:
   ```kotlin
   dependencies {
       coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
   }
   ```
3. **Limpeza completa do cache** (se persistir):
   ```bash
   # Limpar cache do Gradle
   rm -rf ~/.gradle/
   rm -rf android/.gradle/
   rm -rf build/
   
   # Limpar Flutter
   flutter clean
   flutter pub get
   
   # Tentar build
   flutter build apk --debug
   ```

**⚠️ Nota**: Às vezes o cache do Gradle pode ficar corrompido. A limpeza completa resolve a maioria dos problemas de dependência.

### **2. Notificações não aparecem**

#### **Causa: Restrições de OEM (Xiaomi, Huawei, Samsung, etc.)**
**Solução para o usuário:**
1. Ir em **Configurações** > **Bateria** > **Otimização de bateria**
2. Encontrar o app **Vida+** e marcar como "Não otimizar"
3. Em **Configurações** > **Apps** > **Vida+** > **Notificações**
4. Garantir que todas as permissões estão ativadas

**Links úteis:**
- [dontkillmyapp.com](https://dontkillmyapp.com) - Guia específico por marca

#### **Causa: Permissões insuficientes no Android 13+**
**Verificar no app:**
1. Ir em **Perfil** > **Configurações de Notificação**
2. Clicar em "Verificar Permissões"
3. Aceitar todas as permissões solicitadas

### **3. Notificações aparecem com atraso**

#### **Modo de economia de energia ativo**
- Verificar se o modo "Economia de energia" está ativo
- Desativar ou adicionar o app nas exceções

#### **Modo "Não perturbar" ativo**
- Verificar configurações de "Não perturbar"
- Adicionar exceção para o app Vida+

### **4. App funciona no WiFi mas não em dados móveis**
- Notificações locais não dependem de internet
- Se há problemas, pode ser restrição do sistema

## 🔧 Como Usar as Ferramentas de Depuração

### **1. Modo Debug (apenas desenvolvedores)**
```dart
// No console, você verá:
✅ Scheduled EXACT alarm for habit: Exercício at 07:00 (next: 2024-...)
⚠️ Scheduled INEXACT alarm for habit: Leitura at 21:00 (exact alarms not available)
❌ Error scheduling habit reminder for Meditação: [erro detalhado]
```

### **2. Botões na UI (Perfil > Notificações)**
- **Debug**: Mostra status de todas as notificações no console
- **Reset**: Limpa todas as notificações e recria

### **3. Verificação Manual**
```dart
// Para testar manualmente:
final notificationService = NotificationService();
await notificationService.debugNotifications();
```

## 📱 Configurações Recomendadas por Marca

### **Xiaomi/Redmi (MIUI)**
1. Configurações > Apps > Gerenciar apps > Vida+
2. Autostart: **Ativar**
3. Restrições de bateria: **Sem restrições**
4. Salvar energia: **Desativar**

### **Huawei/Honor (EMUI)**
1. Configurações > Bateria > Inicialização de app
2. Vida+: **Ativar gerenciamento manual**
3. Auto-inicialização: **Ativar**
4. Atividade secundária: **Ativar**
5. Executar em segundo plano: **Ativar**

### **Samsung (One UI)**
1. Configurações > Bateria e cuidados do dispositivo
2. Bateria > Uso em segundo plano
3. Vida+: **Ativar**
4. Apps nunca suspensos: **Adicionar Vida+**

### **OnePlus (OxygenOS)**
1. Configurações > Bateria > Otimização de bateria
2. Vida+: **Não otimizar**
3. Apps importantes em segundo plano: **Adicionar Vida+**

## 🔍 Logs Importantes

### **Permissões:**
```
🔔 Notification permission: true
⏰ Exact alarms permission: true
✅ Final status - Notifications: true, Exact alarms: true
```

### **Agendamento:**
```
🎯 Starting to schedule habit: Exercício
📅 Scheduling for today: 2024-12-19 07:00:00.000
🕐 Scheduled timezone: 2024-12-19 07:00:00.000-0300
🔒 Can schedule exact alarms: true
🆔 Notification ID: 1047177371
✅ Scheduled EXACT alarm for habit: Exercício at 07:00 (next: 2024-12-19 07:00:00.000-0300)
🔍 Verification - Notification scheduled: true
```

### **Sucesso (antigo):**
```
✅ Scheduled EXACT alarm for habit: [nome] at [hora] (next: [timestamp])
```

### **Aviso (antigo):**
```
⚠️ Scheduled INEXACT alarm for habit: [nome] at [hora] (exact alarms not available)
```

### **Erro (antigo):**
```
❌ Error scheduling habit reminder for [nome]: [detalhe do erro]
```

## 🚀 Próximos Passos

1. **Teste as ferramentas de debug** para verificar se as notificações estão sendo agendadas
2. **Configure as permissões** seguindo o guia da sua marca de celular
3. **Use os botões de Reset** se as notificações estiverem "presas"
4. **Monitore os logs** durante desenvolvimento para identificar padrões

## 📞 Suporte

Se os problemas persistirem, verifique:
1. Os logs no console quando criar/editar hábitos
2. Se as permissões estão todas concedidas
3. Se o horário do sistema está correto
4. Se não há conflitos com outros apps de alarme 