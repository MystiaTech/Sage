import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../models/food_item.dart';
import '../controllers/inventory_controller.dart';
import 'add_item_screen.dart';

/// Screen displaying all inventory items
class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(inventoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search functionality
            },
          ),
        ],
      ),
      body: inventoryState.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items yet!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first item',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          // Sort by expiration date (soonest first)
          final sortedItems = List<FoodItem>.from(items)
            ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedItems.length,
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              return _buildInventoryCard(context, ref, item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(inventoryControllerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddItemScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildInventoryCard(
      BuildContext context, WidgetRef ref, FoodItem item) {
    final daysUntil = item.daysUntilExpiration;
    final status = item.expirationStatus;
    final statusColor = Color(status.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Text(
            item.location.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${item.location.displayName} • ${item.quantity} ${item.unit ?? "items"}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  item.isExpired
                      ? Icons.warning
                      : item.isExpiringSoon
                          ? Icons.schedule
                          : Icons.check_circle,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  item.isExpired
                      ? 'Expired ${-daysUntil} days ago'
                      : 'Expires in $daysUntil days',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Exp: ${DateFormat('MMM dd, yyyy').format(item.expirationDate)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Item'),
                  content: Text('Delete ${item.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref
                    .read(inventoryControllerProvider.notifier)
                    .deleteItem(item.key);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} deleted'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
