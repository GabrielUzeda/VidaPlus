import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';
import '../../controllers/habits_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../../core/services/notification_service.dart';

// Página de perfil do usuário
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user;
    _nameController.text = user?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthController>(
        builder: (context, authController, _) {
          final user = authController.user;
          
          return CustomScrollView(
            slivers: [
              // Header com foto de perfil
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: _isEditing ? const Text('Editar Perfil') : null,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Foto de perfil
                        GestureDetector(
                          onTap: _isEditing ? _showImagePicker : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                backgroundImage: _getProfileImage(user),
                                child: _getProfileImage(user) == null
                                    ? Text(
                                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      )
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Nome do usuário
                        if (!_isEditing) ...[
                          Text(
                            user?.name ?? 'Usuário',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (!_isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                    ),
                ],
              ),

              // Conteúdo principal
              if (_isEditing)
                _buildEditForm(authController)
              else
                _buildProfileInfo(authController, user),
            ],
          );
        },
      ),
    );
  }

  // Formulário de edição
  Widget _buildEditForm(AuthController authController) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo de nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite seu nome';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Preview da imagem selecionada
              if (_selectedImage != null) ...[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: authController.isLoading ? null : _cancelEdit,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: authController.isLoading ? null : () => _saveChanges(authController),
                      child: authController.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Informações do perfil (modo visualização)
  Widget _buildProfileInfo(AuthController authController, user) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Consumer<HabitsController>(
          builder: (context, habitsController, _) {
            final todayStats = habitsController.getTodayStats();
            final totalHabits = todayStats['totalHabits'] as int;
            final completedHabits = todayStats['completedHabits'] as int;
            
            return Column(
              children: [
                // Estatísticas simples
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FutureBuilder<int>(
                              future: user?.id != null ? habitsController.getActiveDays(user!.id) : Future.value(0),
                              builder: (context, snapshot) {
                                final activeDays = snapshot.data ?? 0;
                                return _buildStatItem('Dias Ativos', '$activeDays');
                              },
                            ),
                            _buildStatItem('Hábitos', '$totalHabits'),
                            _buildStatItem('Concluídos', '$completedHabits'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Opções do perfil
                _buildProfileOption(
                  icon: Icons.notifications,
                  title: 'Notificações',
                  subtitle: 'Gerenciar lembretes',
                  onTap: _showNotificationSettings,
                ),
                
                Consumer<ThemeController>(
                  builder: (context, themeController, _) {
                    return _buildProfileOption(
                      icon: _getThemeIcon(themeController.themeMode),
                      title: 'Tema do App',
                      subtitle: themeController.themeMode.label,
                      onTap: () => themeController.toggleTheme(),
                    );
                  },
                ),
                
                Consumer<ThemeController>(
                  builder: (context, themeController, _) {
                    return _buildProfileOption(
                      icon: Icons.palette,
                      title: 'Cor do App',
                      subtitle: themeController.primaryColor.label,
                      onTap: () => _showColorPicker(themeController),
                    );
                  },
                ),
                
                _buildProfileOption(
                  icon: Icons.info,
                  title: 'Sobre o App',
                  subtitle: 'Vida+ v1.0.0',
                  onTap: _showAboutDialog,
                ),

                const SizedBox(height: 20),

                // Botão de logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(authController),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Sair da Conta',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Constrói item de estatística
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // Constrói opção do perfil
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // Obtém imagem de perfil (local ou URL)
  ImageProvider? _getProfileImage(user) {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    if (user?.profileImageUrl != null) {
      return NetworkImage(user!.profileImageUrl!);
    }
    return null;
  }

  // Obtém ícone baseado no tema atual
  IconData _getThemeIcon(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  // Mostra seletor de imagem
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null || context.read<AuthController>().user?.profileImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover foto', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Seleciona imagem
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  // Cancela edição
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _selectedImage = null;
      final user = context.read<AuthController>().user;
      _nameController.text = user?.name ?? '';
    });
  }

  // Salva alterações
  Future<void> _saveChanges(AuthController authController) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await authController.updateProfile(
        name: _nameController.text.trim(),
        profileImagePath: _selectedImage?.path,
      );

      setState(() {
        _isEditing = false;
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar perfil: $e')),
      );
    }
  }

  // Mostra configurações de notificação
  void _showNotificationSettings() {
    final notificationService = context.read<NotificationService>();
    final habitsController = context.read<HabitsController>();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications),
              SizedBox(width: 8),
              Text('Notificações'),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<bool>(
                    future: notificationService.getNotificationsEnabled(),
                    builder: (context, snapshot) {
                      final isEnabled = snapshot.data ?? true;
                      
                      return SwitchListTile(
                        title: const Text('Ativar notificações'),
                        subtitle: Text(
                          isEnabled 
                            ? 'Receber lembretes de hábitos'
                            : 'Notificações desativadas'
                        ),
                        value: isEnabled,
                        onChanged: (value) async {
                          await notificationService.setNotificationsEnabled(value);
                          setState(() {});
                        },
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Status das permissões
                  FutureBuilder<bool>(
                    future: notificationService.canScheduleExactAlarms(),
                    builder: (context, snapshot) {
                      final canScheduleExact = snapshot.data ?? false;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: canScheduleExact 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: canScheduleExact ? Colors.green : Colors.orange,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              canScheduleExact ? Icons.check_circle : Icons.warning,
                              color: canScheduleExact ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                canScheduleExact 
                                  ? 'Alarmes exatos: Funcionando'
                                  : 'Alarmes inexatos: Pode ter atraso de alguns minutos',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Botão para verificar permissões
                  TextButton.icon(
                    onPressed: () async {
                      await habitsController.checkNotificationPermissions();
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Verificar Permissões'),
                  ),
                  
                  const SizedBox(height: 16),
                  Text(
                    'As notificações ajudam você a manter seus hábitos em dia!',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  // Mostra diálogo sobre o app
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o Vida+'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versão: 1.0.0'),
            SizedBox(height: 8),
            Text('Desenvolvido com Flutter'),
            SizedBox(height: 8),
            Text('Um app para transformar seus hábitos e melhorar sua vida!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // Mostra diálogo de logout
  void _showLogoutDialog(AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authController.signOut();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  // Mostra seletor de cor
  void _showColorPicker(ThemeController themeController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.palette),
            SizedBox(width: 8),
            Text('Escolher Cor'),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: AppPrimaryColor.values.length,
            itemBuilder: (context, index) {
              final color = AppPrimaryColor.values[index];
              final isSelected = themeController.primaryColor == color;
              
              return GestureDetector(
                onTap: () {
                  themeController.setPrimaryColor(color);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.color,
                    shape: BoxShape.circle,
                    border: isSelected 
                      ? Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 3,
                        )
                      : null,
                  ),
                  child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
} 