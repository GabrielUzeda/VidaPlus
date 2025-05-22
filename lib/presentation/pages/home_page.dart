import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vida_plus/domain/entities/habit.dart';
import 'package:vida_plus/presentation/controllers/auth_controller.dart';
import 'package:vida_plus/presentation/controllers/habit_controller.dart';
import 'package:vida_plus/presentation/pages/habit/create_habit_page.dart';
import 'package:vida_plus/presentation/pages/profile_page.dart';
import 'package:vida_plus/presentation/widgets/habit_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const HabitsPage(),
    const StatsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vida+'),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final habitController = Provider.of<HabitController>(context, listen: false);
    final userId = authController.currentUser?.id;

    if (userId != null) {
      await habitController.loadHabits(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final habitController = Provider.of<HabitController>(context);
    final habits = habitController.habits;
    final isLoading = habitController.isLoading;

    return RefreshIndicator(
      onRefresh: _loadHabits,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${authController.currentUser?.name ?? "Usuário"}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hoje, ${_getFormattedDate()}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Seus hábitos para hoje',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : habits.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Você ainda não tem hábitos cadastrados',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CreateHabitPage(),
                                    ),
                                  ).then((_) => _loadHabits());
                                },
                                child: const Text('Criar um hábito'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: habits.length,
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            return HabitCard(
                              habit: habit,
                              onToggle: (completed) {
                                // Implementar toggle de check-in
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return '${now.day} de ${months[now.month - 1]} de ${now.year}';
  }
}

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final habitController = Provider.of<HabitController>(context, listen: false);
    final userId = authController.currentUser?.id;

    if (userId != null) {
      await habitController.loadHabits(userId);
    }
  }

  void _navigateToCreateHabit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateHabitPage(),
      ),
    ).then((_) => _loadHabits());
  }

  @override
  Widget build(BuildContext context) {
    final habitController = Provider.of<HabitController>(context);
    final habits = habitController.habits;
    final isLoading = habitController.isLoading;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadHabits,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : habits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Você ainda não tem hábitos cadastrados',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _navigateToCreateHabit,
                          child: const Text('Criar um hábito'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: HabitCard(
                          habit: habit,
                          onToggle: (completed) {
                            // Implementar toggle de check-in
                          },
                          showActions: true,
                          onEdit: () {
                            // Navegar para tela de edição
                          },
                          onDelete: () {
                            _showDeleteConfirmation(habit);
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir hábito'),
        content: Text('Tem certeza que deseja excluir o hábito "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final habitController = Provider.of<HabitController>(context, listen: false);
              habitController.deleteHabit(habit.id);
            },
            child: const Text('Excluir'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Página de Estatísticas'),
    );
  }
} 