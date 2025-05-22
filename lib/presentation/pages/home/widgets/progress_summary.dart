import 'package:flutter/material.dart';

// Widget para exibir resumo do progresso diário
class ProgressSummary extends StatelessWidget {
  final Map<String, dynamic> stats;

  const ProgressSummary({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final totalHabits = stats['totalHabits'] as int;
    final completedHabits = stats['completedHabits'] as int;
    final completionRate = stats['completionRate'] as double;
    final pendingHabits = stats['pendingHabits'] as int;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                children: [
                  Icon(
                    Icons.insights,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Progresso de Hoje',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Indicador circular de progresso
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: completionRate,
                        strokeWidth: 8,
                        backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(completionRate * 100).round()}%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Concluído',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Estatísticas detalhadas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    Icons.check_circle,
                    completedHabits.toString(),
                    'Concluídos',
                    Colors.green,
                  ),
                  _buildStatItem(
                    context,
                    Icons.pending,
                    pendingHabits.toString(),
                    'Pendentes',
                    Colors.orange,
                  ),
                  _buildStatItem(
                    context,
                    Icons.list,
                    totalHabits.toString(),
                    'Total',
                    Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              
              // Mensagem motivacional
              if (totalHabits > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getMotivationalIcon(completionRate),
                        color: _getMotivationalColor(completionRate),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getMotivationalMessage(completionRate, completedHabits, totalHabits),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Constrói item de estatística
  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Obtém ícone motivacional baseado no progresso
  IconData _getMotivationalIcon(double completionRate) {
    if (completionRate >= 1.0) return Icons.celebration;
    if (completionRate >= 0.75) return Icons.emoji_emotions;
    if (completionRate >= 0.5) return Icons.thumb_up;
    if (completionRate > 0) return Icons.trending_up;
    return Icons.flag;
  }

  // Obtém cor motivacional baseada no progresso
  Color _getMotivationalColor(double completionRate) {
    if (completionRate >= 1.0) return Colors.purple;
    if (completionRate >= 0.75) return Colors.green;
    if (completionRate >= 0.5) return Colors.blue;
    if (completionRate > 0) return Colors.orange;
    return Colors.grey;
  }

  // Obtém mensagem motivacional baseada no progresso
  String _getMotivationalMessage(double completionRate, int completed, int total) {
    if (completionRate >= 1.0) {
      return 'Incrível! Você completou todos os hábitos hoje! 🎉';
    } else if (completionRate >= 0.75) {
      return 'Ótimo trabalho! Você está quase lá! 💪';
    } else if (completionRate >= 0.5) {
      return 'Bom progresso! Continue assim! 👍';
    } else if (completionRate > 0) {
      return 'Você começou bem! Vamos continuar! 🚀';
    } else {
      return 'Um novo dia, novas oportunidades! Vamos começar! ⭐';
    }
  }
} 