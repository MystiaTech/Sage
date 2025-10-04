import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../inventory/controllers/inventory_controller.dart';
import '../../inventory/screens/add_item_screen.dart';
import '../../inventory/screens/barcode_scanner_screen.dart';
import '../../inventory/screens/inventory_screen.dart';
import '../../settings/screens/settings_screen.dart';

/// Home screen - Dashboard with expiring items and quick actions
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(itemCountProvider);
    final expiringSoon = ref.watch(expiringSoonProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌿 Sage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(itemCountProvider);
          ref.invalidate(expiringSoonProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome to Sage!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your smart kitchen management system',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // Quick Stats Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Stats',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        Icons.inventory_2,
                        'Items in inventory',
                        itemCount.when(
                          data: (count) => '$count',
                          loading: () => '...',
                          error: (_, __) => '0',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        Icons.warning_amber,
                        'Expiring soon',
                        expiringSoon.when(
                          data: (items) => '${items.length}',
                          loading: () => '...',
                          error: (_, __) => '0',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(Icons.shopping_cart, 'Shopping list', '0'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.add_circle_outline,
                      label: 'Add Item',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddItemScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.qr_code_scanner,
                      label: 'Scan Barcode',
                      color: AppColors.info,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BarcodeScannerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.inventory,
                      label: 'View Inventory',
                      color: AppColors.warning2,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InventoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.book,
                      label: 'Recipes',
                      color: AppColors.primaryLight,
                      onTap: () {
                        // TODO: Navigate to recipes
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Recipes coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Getting started or expiring soon list
              expiringSoon.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _buildGettingStarted(context);
                  } else {
                    return _buildExpiringSoonList(context, items);
                  }
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => _buildGettingStarted(context),
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

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGettingStarted(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryLight,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Getting Started',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add your first item to start tracking your kitchen inventory and preventing food waste!',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringSoonList(BuildContext context, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber, color: AppColors.warning2),
            const SizedBox(width: 8),
            Text(
              'Expiring Soon',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'These items expire within 7 days. Use them soon!',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        ...items.take(3).map((item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(
                  item.location.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(item.name),
                subtitle: Text('Expires in ${item.daysUntilExpiration} days'),
                trailing: Icon(
                  Icons.warning,
                  color: Color(item.expirationStatus.colorValue),
                ),
              ),
            )),
      ],
    );
  }
}
