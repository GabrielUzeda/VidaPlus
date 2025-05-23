import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/habits_controller.dart';
import '../../../domain/entities/habit_entity.dart';
import '../../controllers/auth_controller.dart';

// Página de histórico com gráficos de progresso
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _selectedMonth = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HabitsController>(
        builder: (context, controller, _) {
          return CustomScrollView(
            slivers: [
              // Header com seletor de mês
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Histórico'),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _showMonthPicker,
                  ),
                ],
              ),

              // Gráfico de progresso semanal
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progresso dos Últimos 7 Dias',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildWeeklyChart(controller),
                      ),
                    ],
                  ),
                ),
              ),

              // Gráfico mensal
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Últimos 15 Dias - ${DateFormat('MMMM yyyy', 'pt_BR').format(_selectedMonth)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 350,
                        child: _buildMonthlyChart(controller),
                      ),
                    ],
                  ),
                ),
              ),

              // Lista de hábitos e estatísticas
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estatísticas por Hábito',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Lista de hábitos
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = controller.habits[index];
                    return _buildHabitStatCard(habit, controller);
                  },
                  childCount: controller.habits.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Constrói gráfico semanal
  Widget _buildWeeklyChart(HabitsController controller) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final userId = authController.user?.id;
        if (userId == null) {
          return const Center(child: Text('Usuário não encontrado'));
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: controller.getWeeklyHistoryData(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final weekData = snapshot.data ?? [];
            final spots = weekData.map((data) => 
              FlSpot(data['day'].toDouble(), data['progress'].toDouble())
            ).toList();

            return LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
                        return Text(
                          days[value.toInt() % 7],
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 100,
                clipData: FlClipData.all(),
              ),
            );
          },
        );
      },
    );
  }

  // Constrói gráfico mensal
  Widget _buildMonthlyChart(HabitsController controller) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final userId = authController.user?.id;
        if (userId == null) {
          return const Center(child: Text('Usuário não encontrado'));
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: controller.getMonthlyHistoryData(userId, _selectedMonth),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final monthData = snapshot.data ?? [];
            
            // Limita a 15 dias mais recentes para melhor visualização
            final recentData = monthData.length > 15 
                ? monthData.sublist(monthData.length - 15)
                : monthData;
            
            final barGroups = recentData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data['progress'].toDouble(),
                    color: _getBarColor(data['progress'].toDouble()),
                    width: 20, // Largura maior para melhor visibilidade
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ],
              );
            }).toList();

            return RotatedBox(
              quarterTurns: 1, // Rotaciona 90 graus para barras horizontais
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final data = recentData[group.x];
                        final day = data['day'];
                        final progress = data['progress'].toInt();
                        return BarTooltipItem(
                          'Dia $day\n$progress%',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < recentData.length) {
                            final day = recentData[value.toInt()]['day'];
                            return RotatedBox(
                              quarterTurns: -1, // Desfaz a rotação do texto
                              child: Text(
                                '$day',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              '${value.toInt()}%',
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(
                        color: Colors.transparent,
                        strokeWidth: 0,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Constrói card de estatística por hábito
  Widget _buildHabitStatCard(HabitEntity habit, HabitsController controller) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        return FutureBuilder<Map<String, dynamic>>(
          future: controller.getHabitRealStats(habit.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  child: ListTile(
                    leading: const CircularProgressIndicator(),
                    title: Text(habit.name),
                    subtitle: Text(habit.frequency.displayName),
                  ),
                ),
              );
            }

            final stats = snapshot.data ?? {};
            final completionRate = (stats['completionRate'] ?? 0.0).toDouble();
            final currentStreak = stats['currentStreak'] ?? 0;
            final isCompletedToday = controller.isHabitCompletedToday(habit.id);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getProgressColor(completionRate),
                    child: Text(
                      '${completionRate.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(habit.name),
                  subtitle: Text('${habit.frequency.displayName} • Sequência: $currentStreak dias'),
                  trailing: Icon(
                    isCompletedToday ? Icons.check_circle : Icons.pending,
                    color: _getProgressColor(completionRate),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Obtém dados semanais baseados nos hábitos reais
  List<FlSpot> _getWeeklyData(HabitsController controller) {
    // Usar dados reais será implementado via FutureBuilder na UI
    // Por enquanto retorna dados vazios para forçar o uso do FutureBuilder
    return List.generate(7, (index) => FlSpot(index.toDouble(), 0));
  }

  // Obtém dados mensais baseados nos hábitos reais 
  List<FlSpot> _getMonthlyData(HabitsController controller) {
    // Usar dados reais será implementado via FutureBuilder na UI
    // Por enquanto retorna dados vazios para forçar o uso do FutureBuilder
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    return List.generate(daysInMonth, (index) => FlSpot((index + 1).toDouble(), 0));
  }

  // Obtém cor da barra baseada no progresso
  Color _getBarColor(double progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return Colors.orange;
    return Colors.red;
  }

  // Obtém cor do progresso
  Color _getProgressColor(double progress) {
    if (progress >= 70) return Colors.green;
    if (progress >= 40) return Colors.orange;
    return Colors.red;
  }

  // Mostra seletor de mês
  void _showMonthPicker() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    
    if (selected != null) {
      setState(() {
        _selectedMonth = selected;
      });
    }
  }
} 