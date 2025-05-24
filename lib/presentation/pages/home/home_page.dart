import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/habits_controller.dart';
import '../../../domain/entities/habit_entity.dart';
import '../../../core/services/notification_service.dart';
import 'widgets/habit_card.dart';
import 'widgets/progress_summary.dart';
import 'widgets/add_habit_dialog.dart';
import 'history_page.dart';
import 'profile_page.dart';

// Página principal do aplicativo
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermissions();
      _loadUserData();
    });
  }

  // Solicita permissões de notificação na inicialização
  Future<void> _requestNotificationPermissions() async {
    try {
      final notificationService = context.read<NotificationService>();
      
      // Inicializa o serviço
      await notificationService.initialize();
      
      // Solicita permissões
      final hasPermission = await notificationService.requestPermission();
      
      if (!hasPermission) {
        // Mostra diálogo explicativo se não tiver permissão
        if (mounted) {
          _showPermissionDialog();
        }
      } else {
        // Verifica se pode agendar alarmes exatos
        final canScheduleExact = await notificationService.canScheduleExactAlarms();
        if (!canScheduleExact && mounted) {
          _showExactAlarmDialog();
        }
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  // Mostra diálogo sobre permissões de notificação
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text('Permissões Necessárias'),
            ),
          ],
        ),
        content: const Text(
          'Para funcionar corretamente, o Vida+ precisa enviar notificações para lembrar você dos seus hábitos.\n\n'
          'Por favor, ative as notificações nas configurações do sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agora não'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Tenta solicitar permissão novamente
              final notificationService = context.read<NotificationService>();
              await notificationService.requestPermission();
            },
            child: const Text('Permitir'),
          ),
        ],
      ),
    );
  }

  // Mostra diálogo sobre alarmes exatos
  void _showExactAlarmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text('Alarmes Precisos'),
            ),
          ],
        ),
        content: const Text(
          'Para que as notificações sejam enviadas no horário exato, é recomendado ativar a permissão de "Alarmes e lembretes" nas configurações do sistema.\n\n'
          'Sem essa permissão, as notificações podem ter alguns minutos de atraso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ok, entendi'),
          ),
        ],
      ),
    );
  }

  // Carrega dados do usuário
  void _loadUserData() {
    final authController = context.read<AuthController>();
    final habitsController = context.read<HabitsController>();
    
    if (authController.user != null) {
      habitsController.loadUserHabits(authController.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboardPage(),
      _buildProgressPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
    );
  }

  // Constrói a AppBar
  PreferredSizeWidget _buildAppBar() {
    final titles = ['Dashboard', 'Progresso', 'Perfil'];
    
    return AppBar(
      title: Text(titles[_currentIndex]),
      actions: [
        if (_currentIndex == 0)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              _showLogoutDialog();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Sair'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Constrói a navegação inferior
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Progresso',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  // Constrói o FAB para adicionar hábitos
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _showAddHabitDialog,
      child: const Icon(Icons.add),
    );
  }

  // Página do Dashboard
  Widget _buildDashboardPage() {
    return Consumer2<AuthController, HabitsController>(
      builder: (context, authController, habitsController, _) {
        if (habitsController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (habitsController.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar dados',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(habitsController.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadUserData,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadUserData(),
          child: CustomScrollView(
            slivers: [
              // Saudação
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${authController.user?.name ?? 'Usuário'}! 👋',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy', 'pt_BR').format(DateTime.now()),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Resumo do progresso
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ProgressSummary(
                    stats: habitsController.getTodayStats(),
                  ),
                ),
              ),

              // Lista de hábitos
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Seus Hábitos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${habitsController.habits.length} hábitos',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (habitsController.habits.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_nature,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum hábito ainda',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comece criando seu primeiro hábito saudável!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showAddHabitDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Criar Hábito'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = habitsController.habits[index];
                      final isCompleted = habitsController.isHabitCompletedToday(habit.id);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: HabitCard(
                          habit: habit,
                          isCompleted: isCompleted,
                          onTap: () => _handleHabitTap(habit, isCompleted),
                          onEdit: () => _showEditHabitDialog(habit),
                          onDelete: () => _showDeleteHabitDialog(habit),
                        ),
                      );
                    },
                    childCount: habitsController.habits.length,
                  ),
                ),

              // Espaço extra para o FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        );
      },
    );
  }

  // Página de Progresso - agora usa a HistoryPage
  Widget _buildProgressPage() {
    return const HistoryPage();
  }

  // Página de Perfil - agora usa a ProfilePage
  Widget _buildProfilePage() {
    return const ProfilePage();
  }

  // Manipula toque no hábito (check-in)
  void _handleHabitTap(HabitEntity habit, bool isCompleted) {
    if (isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hábito já foi realizado hoje! 🎉'),
        ),
      );
      return;
    }

    final authController = context.read<AuthController>();
    final habitsController = context.read<HabitsController>();

    habitsController.checkInHabit(
      habitId: habit.id,
      userId: authController.user!.id,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${habit.name} concluído! 🎉'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Mostra diálogo para adicionar hábito
  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddHabitDialog(),
    );
  }

  // Mostra diálogo para editar hábito
  void _showEditHabitDialog(HabitEntity habit) {
    showDialog(
      context: context,
      builder: (context) => AddHabitDialog(habit: habit),
    );
  }

  // Mostra diálogo para deletar hábito
  void _showDeleteHabitDialog(HabitEntity habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Hábito'),
        content: Text('Tem certeza que deseja excluir "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HabitsController>().deleteHabit(habit.id);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // Mostra diálogo de logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthController>().signOut();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
} 