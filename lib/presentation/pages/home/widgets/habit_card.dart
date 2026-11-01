import 'package:flutter/material.dart';
import '../../../../domain/entities/habit_entity.dart';

// Widget de card para exibir um hábito
class HabitCard extends StatefulWidget {
  final HabitEntity habit;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _checkController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159, // 360 degrees in radians
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    ));

    if (widget.isCompleted) {
      _checkController.forward();
    } else {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _pulseController.stop();
        _checkController.forward();
      } else {
        _checkController.reverse();
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.isCompleted ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.isCompleted
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone de check animado e impressionante
              _buildAnimatedCheckIcon(),
              
              const SizedBox(width: 16),
              
              // Informações do hábito
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
                        color: widget.isCompleted 
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          widget.habit.frequency == HabitFrequency.daily
                              ? Icons.today
                              : Icons.date_range,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.habit.frequency.displayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (widget.habit.recommendedTime != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.habit.recommendedTime!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Menu de opções
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      widget.onEdit();
                      break;
                    case 'delete':
                      widget.onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Excluir'),
                      ],
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

  Widget _buildAnimatedCheckIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _checkController]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isCompleted ? _checkAnimation.value : _pulseAnimation.value,
          child: Transform.rotate(
            angle: widget.isCompleted ? _rotationAnimation.value : 0,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.isCompleted
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600,
                          Colors.green.shade800,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                          Theme.of(context).colorScheme.surfaceContainer,
                        ],
                      ),
                boxShadow: widget.isCompleted
                    ? [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.2),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                          spreadRadius: 4,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: widget.isCompleted
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        // Efeito de brilho
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        // Ícone de check
                        const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28,
                          weight: 800,
                        ),
                        // Partículas de celebração
                        if (_checkAnimation.value > 0.7) ...[
                          Positioned(
                            top: 5,
                            right: 8,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 6,
                            child: Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            left: 4,
                            child: Container(
                              width: 2,
                              height: 2,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                  : Icon(
                      Icons.circle_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 28,
                    ),
            ),
          ),
        );
      },
    );
  }
} 