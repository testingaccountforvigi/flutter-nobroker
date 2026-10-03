import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/reminders_repository.dart';
import '../../../core/network/dio_client.dart';

final remindersRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return RemindersRepository(dio);
});

final remindersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repository = ref.watch(remindersRepositoryProvider);
  return repository.getMyReminders();
});

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateReminderDialog(context, ref),
          ),
        ],
      ),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: AppSpacing.md),
                  Text('No reminders yet', style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Create reminders for rent payments,\nnotice periods, or custom events',
                    style: AppTypography.body.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomButton(
                    text: 'Create Reminder',
                    onPressed: () => _showCreateReminderDialog(context, ref),
                  ),
                ],
              ),
            );
          }

          final pending = reminders.where((r) => !r['completed']).toList();
          final completed = reminders.where((r) => r['completed']).toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (pending.isNotEmpty) ...[
                Text('Pending', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.sm),
                ...pending.map((reminder) => _ReminderCard(
                  reminder: reminder,
                  onComplete: () => _markComplete(context, ref, reminder['id']),
                  onDelete: () => _deleteReminder(context, ref, reminder['id']),
                )),
              ],
              if (pending.isNotEmpty && completed.isNotEmpty)
                const SizedBox(height: AppSpacing.lg),
              if (completed.isNotEmpty) ...[
                Text('Completed', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.sm),
                ...completed.map((reminder) => _ReminderCard(
                  reminder: reminder,
                  onDelete: () => _deleteReminder(context, ref, reminder['id']),
                )),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: AppSpacing.md),
              CustomButton(
                text: 'Retry',
                onPressed: () => ref.refresh(remindersProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateReminderDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CreateReminderDialog(
        onCreated: () => ref.refresh(remindersProvider),
      ),
    );
  }

  Future<void> _markComplete(BuildContext context, WidgetRef ref, String id) async {
    try {
      final repository = ref.read(remindersRepositoryProvider);
      await repository.markComplete(id);
      ref.invalidate(remindersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder marked as complete')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteReminder(BuildContext context, WidgetRef ref, String id) async {
    try {
      final repository = ref.read(remindersRepositoryProvider);
      await repository.deleteReminder(id);
      ref.invalidate(remindersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _ReminderCard extends StatelessWidget {
  final Map<String, dynamic> reminder;
  final VoidCallback? onComplete;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.parse(reminder['dueDate']);
    final isOverdue = dueDate.isBefore(DateTime.now()) && !reminder['completed'];
    final type = reminder['type'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: reminder['completed']
              ? Colors.grey[300]
              : isOverdue
                  ? Colors.red[100]
                  : AppColors.accent.withOpacity(0.1),
          child: Icon(
            _getIconForType(type),
            color: reminder['completed']
                ? Colors.grey
                : isOverdue
                    ? Colors.red
                    : AppColors.accent,
          ),
        ),
        title: Text(
          reminder['title'],
          style: reminder['completed']
              ? AppTypography.body.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                )
              : AppTypography.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Due: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
              style: TextStyle(
                color: isOverdue ? Colors.red : Colors.grey[600],
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (reminder['amount'] != null) ...[
              const SizedBox(height: 2),
              Text(
                '₹${reminder['amount'].toStringAsFixed(0)}',
                style: AppTypography.body.copyWith(color: AppColors.accent),
              ),
            ],
            if (reminder['notes'] != null && reminder['notes'].isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                reminder['notes'],
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onComplete != null)
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                color: Colors.green,
                onPressed: onComplete,
                tooltip: 'Mark Complete',
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'RENT':
        return Icons.home;
      case 'NOTICE_PERIOD':
        return Icons.notifications_active;
      case 'AGREEMENT':
        return Icons.description;
      default:
        return Icons.event;
    }
  }
}

class _CreateReminderDialog extends ConsumerStatefulWidget {
  final VoidCallback onCreated;

  const _CreateReminderDialog({required this.onCreated});

  @override
  ConsumerState<_CreateReminderDialog> createState() => _CreateReminderDialogState();
}

class _CreateReminderDialogState extends ConsumerState<_CreateReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'RENT';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Reminder'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'RENT', child: Text('Rent Payment')),
                  DropdownMenuItem(value: 'NOTICE_PERIOD', child: Text('Notice Period')),
                  DropdownMenuItem(value: 'AGREEMENT', child: Text('Agreement Renewal')),
                  DropdownMenuItem(value: 'CUSTOM', child: Text('Custom')),
                ],
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a title' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _amountController,
                label: 'Amount (Optional)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _createReminder,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _createReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(remindersRepositoryProvider);
      await repository.createReminder({
        'type': _type,
        'title': _titleController.text,
        'dueDate': _dueDate.toIso8601String(),
        'amount': _amountController.text.isNotEmpty
            ? double.parse(_amountController.text)
            : null,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
