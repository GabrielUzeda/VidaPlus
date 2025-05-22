import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/habits_controller.dart';
import '../../../domain/entities/habit_entity.dart';

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
                        'Progresso Mensal - ${DateFormat('MMMM yyyy', 'pt_BR').format(_selectedMonth)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
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
    final weekData = _getWeeklyData(controller);
    
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
            spots: weekData,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: 100,
      ),
    );
  }

  // Constrói gráfico mensal
  Widget _buildMonthlyChart(HabitsController controller) {
    final monthData = _getMonthlyData(controller);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: monthData.map((data) {
          return BarChartGroupData(
            x: data.x.toInt(),
            barRods: [
              BarChartRodData(
                toY: data.y,
                color: _getBarColor(data.y),
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Constrói card de estatística por hábito
  Widget _buildHabitStatCard(HabitEntity habit, HabitsController controller) {
    // Simula estatísticas do hábito (em produção viria do controller)
    final completionRate = (60 + (habit.name.length * 5)) % 100;
    final streak = (habit.name.length * 3) % 15;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getProgressColor(completionRate.toDouble()),
            child: Text(
              '$completionRate%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(habit.name),
          subtitle: Text('${habit.frequency.displayName} • Sequência: $streak dias'),
          trailing: Icon(
            completionRate > 70 ? Icons.trending_up : Icons.trending_down,
            color: _getProgressColor(completionRate.toDouble()),
          ),
        ),
      ),
    );
  }

  // Obtém dados semanais (simulados)
  List<FlSpot> _getWeeklyData(HabitsController controller) {
    return List.generate(7, (index) {
      final progress = 20 + (index * 15) + (DateTime.now().day % 10);
      return FlSpot(index.toDouble(), progress.toDouble().clamp(0, 100));
    });
  }

  // Obtém dados mensais (simulados) 
  List<FlSpot> _getMonthlyData(HabitsController controller) {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final progress = 30 + (day * 2) + (day % 7 * 10);
      return FlSpot(day.toDouble(), progress.toDouble().clamp(0, 100));
    });
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