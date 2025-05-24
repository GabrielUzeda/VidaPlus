# 🖼️ Debug da Foto de Perfil - Vida+

## 🔍 Como verificar se a foto está sendo carregada

### **1. Logs que você deve observar no console:**

#### **Ao abrir a página de perfil:**
```
👤 Current user: [Nome do usuário]
👤 User ID: [ID do Firebase]
👤 User email: [email@example.com]
👤 Profile image URL: [URL da imagem ou null]
👤 Created at: [data]
👤 Updated at: [data]
```

#### **Ao tentar carregar imagem:**
```
🖼️ Getting profile image for user: [Nome]
🖼️ Selected image: null
🖼️ User profile URL: [URL ou null]
🖼️ Using network image: [URL] (se tiver URL)
🖼️ No image available, showing fallback (se não tiver)
```

#### **Ao salvar foto nova:**
```
💾 Saving profile changes...
💾 Name: [Nome]
💾 Image path: [caminho do arquivo]
💾 Profile updated successfully
💾 Updated user profile URL: [nova URL]
```

### **2. Possíveis problemas e soluções:**

#### **❌ Problema: `User profile URL: null`**
**Causa**: Usuário nunca fez upload de foto
**Solução**: Fazer upload de uma foto pela primeira vez

#### **❌ Problema: `Error loading profile image: [erro de rede]`**
**Causa**: URL da imagem inválida ou problemas de conectividade
**Soluções**:
- Verificar conexão com internet
- Verificar se URL do Firebase Storage é válida
- Tentar fazer upload de nova foto

#### **❌ Problema: Foto não aparece após upload**
**Causa**: Cache do widget ou estado não atualizado
**Soluções**:
- Hot restart (R maiúsculo no terminal)
- Reinstalar o app
- Verificar se `profileImageUrl` foi atualizado no console

#### **❌ Problema: Erro de permissões no Firebase Storage**
**Causa**: Regras do Firebase Storage muito restritivas
**Solução**: Verificar regras no Console do Firebase

#### **🚨 ERRO ESPECÍFICO: `StorageException Code: -13040`**
**Causa**: Problema de permissões ou configuração do Firebase Storage
**Soluções prioritárias**:

1. **Configurar regras do Firebase Storage**:
   - Vá em [Firebase Console](https://console.firebase.google.com)
   - Selecione seu projeto
   - Vá em **Storage** → **Rules**
   - Substitua as regras atuais por:
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       // Permite leitura e escrita para usuários autenticados
       match /{allPaths=**} {
         allow read, write: if request.auth != null;
       }
       
       // Regra específica para imagens de perfil
       match /profile_images/{userId}/{allPaths=**} {
         allow read: if true; // Permite leitura pública
         allow write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

2. **Verificar se Firebase Storage está ativado**:
   - No Console Firebase → Storage
   - Se não estiver ativado, clique em "Começar"
   - Escolha o modo "Teste" inicialmente

3. **Verificar configuração do projeto**:
   - Arquivo `google-services.json` atualizado
   - Firebase inicializado corretamente no app

### **3. Melhorias implementadas:**

✅ **Carregamento com feedback visual**: Loading indicator enquanto carrega
✅ **Tratamento de erro robusto**: Fallback para letra inicial se imagem falhar
✅ **Logs detalhados**: Para facilitar debugging
✅ **Verificação de URL vazia**: Não tenta carregar URLs vazias
✅ **Debug automático**: Logs aparecem automaticamente ao abrir o perfil

### **4. Como testar:**

1. **Abra o app e vá para Perfil**
2. **Observe os logs no console** - deve mostrar informações do usuário
3. **Toque no ícone de editar (✏️)**
4. **Toque na foto de perfil** - deve abrir seletor de imagem
5. **Escolha uma foto** - deve aparecer preview
6. **Toque em "Salvar"** - deve fazer upload e atualizar
7. **Verifique os logs** - deve mostrar nova URL da imagem
8. **Saia do modo edição** - foto deve aparecer carregada

### **5. Estrutura de arquivos importante:**

```
lib/
├── data/
│   ├── datasources/
│   │   └── firebase_auth_datasource.dart  # Upload para Firebase Storage
│   └── repositories_impl/
│       └── auth_repository_impl.dart      # Interface para upload
├── domain/
│   ├── entities/
│   │   └── user_entity.dart               # Entidade com profileImageUrl
│   └── usecases/
│       └── update_profile_usecase.dart    # Lógica de atualização
└── presentation/
    ├── controllers/
    │   └── auth_controller.dart           # Gerencia estado do usuário
    └── pages/home/
        └── profile_page.dart              # UI da página de perfil
```

### **6. Se ainda não funcionar:**

1. **Verifique no Firebase Console**:
   - Vá em Firestore → `users` → `[seu_user_id]`
   - Verifique se campo `profileImageUrl` existe e tem valor

2. **Verifique no Firebase Storage**:
   - Vá em Storage → `profile_images`
   - Verifique se sua imagem foi carregada

3. **Teste com URL externa**:
   - Use uma URL de imagem pública para testar
   - Ex: `https://picsum.photos/200/200`

4. **Logs de erro específicos**:
   - Procure por `❌ Error loading profile image`
   - Pode indicar problema de URL ou rede

## 🚀 Status das melhorias

- ✅ Logs detalhados implementados
- ✅ Tratamento de erro melhorado  
- ✅ Loading indicator adicionado
- ✅ Fallback para letra inicial
- ✅ Verificação de URL vazia
- ✅ Debug automático na inicialização 