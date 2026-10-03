import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/movers_repository.dart';
import '../../../core/network/dio_client.dart';

final moversRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return MoversRepository(dio);
});

final moversProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repository = ref.watch(moversRepositoryProvider);
  return repository.getAllMovers();
});

final myMovingRequestsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repository = ref.watch(moversRepositoryProvider);
  return repository.getMyRequests();
});

class MoversScreen extends ConsumerStatefulWidget {
  const MoversScreen({super.key});

  @override
  ConsumerState<MoversScreen> createState() => _MoversScreenState();
}

class _MoversScreenState extends ConsumerState<MoversScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Packers & Movers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Requests'),
            Tab(text: 'Find Movers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyRequestsTab(),
          _FindMoversTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRequestDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  void _showCreateRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateMovingRequestDialog(
        onCreated: () {
          ref.refresh(myMovingRequestsProvider);
          _tabController.animateTo(0);
        },
      ),
    );
  }
}

class _MyRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myMovingRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping, size: 64, color: Colors.grey[400]),
                const SizedBox(height: AppSpacing.md),
                Text('No moving requests yet', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Create a request to get quotes\nfrom packers and movers',
                  style: AppTypography.body.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _MovingRequestCard(request: request);
          },
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
              onPressed: () => ref.refresh(myMovingRequestsProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _FindMoversTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moversAsync = ref.watch(moversProvider);

    return moversAsync.when(
      data: (movers) {
        if (movers.isEmpty) {
          return const Center(child: Text('No movers available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: movers.length,
          itemBuilder: (context, index) {
            final mover = movers[index];
            return _MoverCard(mover: mover);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _MovingRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const _MovingRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final moveDate = DateTime.parse(request['moveDate']);
    final status = request['status'] as String;
    final quotes = request['quotes'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(status).withOpacity(0.1),
              child: Icon(
                Icons.local_shipping,
                color: _getStatusColor(status),
              ),
            ),
            title: Text(
              '${request['origin']} → ${request['destination']}',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Move Date: ${DateFormat('MMM dd, yyyy').format(moveDate)}'),
                Text('Property Size: ${request['propertySize']}'),
                Text('Status: ${_getStatusLabel(status)}',
                    style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: Chip(
              label: Text('${quotes.length} Quotes'),
              backgroundColor: AppColors.accent.withOpacity(0.1),
            ),
          ),
          if (quotes.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quotes Received:', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  ...quotes.map((quote) => _QuoteItem(
                    quote: quote,
                    requestId: request['id'],
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'QUOTED':
        return Colors.blue;
      case 'BOOKED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.grey;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    return status.replaceAll('_', ' ').toLowerCase().split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}

class _QuoteItem extends ConsumerWidget {
  final Map<String, dynamic> quote;
  final String requestId;

  const _QuoteItem({required this.quote, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mover = quote['mover'];
    final price = quote['price'];
    final estimatedHours = quote['estimatedHours'];
    final status = quote['status'];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: status == 'ACCEPTED' ? Colors.green[50] : null,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(mover['name'][0]),
        ),
        title: Text(mover['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('₹${price.toStringAsFixed(0)} • $estimatedHours hours'),
            Text('Rating: ${mover['rating'].toStringAsFixed(1)} ⭐'),
            if (quote['inclusions'] != null)
              Text(quote['inclusions'], style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: status == 'SENT'
            ? TextButton(
                onPressed: () => _acceptQuote(context, ref, quote['id']),
                child: const Text('Accept'),
              )
            : status == 'ACCEPTED'
                ? const Icon(Icons.check_circle, color: Colors.green)
                : Text(status, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Future<void> _acceptQuote(BuildContext context, WidgetRef ref, String quoteId) async {
    try {
      final repository = ref.read(moversRepositoryProvider);
      await repository.acceptQuote(quoteId);
      ref.invalidate(myMovingRequestsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quote accepted! Booking confirmed')),
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

class _MoverCard extends StatelessWidget {
  final Map<String, dynamic> mover;

  const _MoverCard({required this.mover});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withOpacity(0.1),
          child: Text(
            mover['name'][0],
            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(mover['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${mover['rating'].toStringAsFixed(1)} (${mover['reviewCount']} reviews)'),
              ],
            ),
            if (mover['description'] != null) ...[
              const SizedBox(height: 4),
              Text(
                mover['description'],
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Show mover details
        },
      ),
    );
  }
}

class _CreateMovingRequestDialog extends ConsumerStatefulWidget {
  final VoidCallback onCreated;

  const _CreateMovingRequestDialog({required this.onCreated});

  @override
  ConsumerState<_CreateMovingRequestDialog> createState() => _CreateMovingRequestDialogState();
}

class _CreateMovingRequestDialogState extends ConsumerState<_CreateMovingRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  String _propertySize = '1BHK';
  DateTime _moveDate = DateTime.now().add(const Duration(days: 14));
  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Moving Request'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _originController,
                label: 'From Address',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _destinationController,
                label: 'To Address',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _propertySize,
                decoration: const InputDecoration(labelText: 'Property Size'),
                items: const [
                  DropdownMenuItem(value: '1BHK', child: Text('1 BHK')),
                  DropdownMenuItem(value: '2BHK', child: Text('2 BHK')),
                  DropdownMenuItem(value: '3BHK', child: Text('3 BHK')),
                  DropdownMenuItem(value: '4BHK', child: Text('4 BHK')),
                  DropdownMenuItem(value: 'Villa', child: Text('Villa/Independent House')),
                ],
                onChanged: (value) => setState(() => _propertySize = value!),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Move Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_moveDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _notesController,
                label: 'Additional Notes (Optional)',
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items to Move (${_items.length})', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              if (_items.isNotEmpty)
                ...(_items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return ListTile(
                    dense: true,
                    title: Text('${item['name']} (x${item['quantity']})'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => setState(() => _items.removeAt(index)),
                    ),
                  );
                })),
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
          onPressed: _isLoading ? null : _createRequest,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _moveDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _moveDate = picked);
    }
  }

  void _addItem() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _items.add({
                    'name': nameController.text,
                    'quantity': int.tryParse(quantityController.text) ?? 1,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _createRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(moversRepositoryProvider);
      await repository.createMovingRequest({
        'origin': _originController.text,
        'destination': _destinationController.text,
        'propertySize': _propertySize,
        'moveDate': _moveDate.toIso8601String(),
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
        'items': _items,
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Moving request created! You will receive quotes soon.')),
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
