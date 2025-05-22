import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/habit_entity.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/habits_controller.dart';

// Diálogo para adicionar ou editar hábitos
class AddHabitDialog extends StatefulWidget {
  final HabitEntity? habit; // Se fornecido, será edição

  const AddHabitDialog({
    super.key,
    this.habit,
  });

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  HabitFrequency _frequency = HabitFrequency.daily;
  TimeOfDay? _recommendedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Se estamos editando, preenche os campos
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _frequency = widget.habit!.frequency;
      
      if (widget.habit!.recommendedTime != null) {
        final timeParts = widget.habit!.recommendedTime!.split(':');
        if (timeParts.length == 2) {
          final hour = int.tryParse(timeParts[0]);
          final minute = int.tryParse(timeParts[1]);
          if (hour != null && minute != null) {
            _recommendedTime = TimeOfDay(hour: hour, minute: minute);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Salva o hábito
  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = context.read<AuthController>();
      final habitsController = context.read<HabitsController>();

      if (authController.user == null) {
        throw Exception('Usuário não autenticado');
      }

      final recommendedTimeString = _recommendedTime != null
          ? '${_recommendedTime!.hour.toString().padLeft(2, '0')}:${_recommendedTime!.minute.toString().padLeft(2, '0')}'
          : null;

      if (widget.habit == null) {
        // Criar novo hábito
        await habitsController.createHabit(
          userId: authController.user!.id,
          name: _nameController.text.trim(),
          frequency: _frequency,
          recommendedTime: recommendedTimeString,
        );
      } else {
        // Editar hábito existente
        final updatedHabit = widget.habit!.copyWith(
          name: _nameController.text.trim(),
          frequency: _frequency,
          recommendedTime: recommendedTimeString,
          updatedAt: DateTime.now(),
        );
        
        await habitsController.updateHabit(updatedHabit);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.habit == null
                  ? 'Hábito criado com sucesso! 🎉'
                  : 'Hábito atualizado com sucesso! ✅',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar hábito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Seleciona horário recomendado
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _recommendedTime ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        _recommendedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Editar Hábito' : 'Novo Hábito',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Campo nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do hábito',
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Beber 2L de água',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite o nome do hábito';
                  }
                  if (value.trim().length < 3) {
                    return 'Nome deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Frequência
              Text(
                'Frequência',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<HabitFrequency>(
                      title: const Text('Diário'),
                      subtitle: const Text('Todo dia'),
                      value: HabitFrequency.daily,
                      groupValue: _frequency,
                      onChanged: (value) {
                        setState(() {
                          _frequency = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<HabitFrequency>(
                      title: const Text('Semanal'),
                      subtitle: const Text('1x por semana'),
                      value: HabitFrequency.weekly,
                      groupValue: _frequency,
                      onChanged: (value) {
                        setState(() {
                          _frequency = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Horário recomendado
              Text(
                'Horário Recomendado (Opcional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _recommendedTime != null
                              ? '${_recommendedTime!.hour.toString().padLeft(2, '0')}:${_recommendedTime!.minute.toString().padLeft(2, '0')}'
                              : 'Toque para definir um horário',
                          style: TextStyle(
                            color: _recommendedTime != null
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (_recommendedTime != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _recommendedTime = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              
              if (_recommendedTime != null) ...[
                const SizedBox(height: 8),
                Text(
                  '💡 Você receberá uma notificação neste horário',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveHabit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Salvar' : 'Criar'),
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
} 