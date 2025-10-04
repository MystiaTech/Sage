import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_item.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/inventory_repository_impl.dart';

/// Provider for the inventory repository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl();
});

/// Provider for the inventory controller
final inventoryControllerProvider =
    StateNotifierProvider<InventoryController, AsyncValue<List<FoodItem>>>(
  (ref) {
    final repository = ref.watch(inventoryRepositoryProvider);
    return InventoryController(repository);
  },
);

/// Controller for managing inventory state
class InventoryController extends StateNotifier<AsyncValue<List<FoodItem>>> {
  final InventoryRepository _repository;

  InventoryController(this._repository) : super(const AsyncValue.loading()) {
    loadItems();
  }

  /// Load all items from the database
  Future<void> loadItems() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getAllItems();
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Add a new item
  Future<void> addItem(FoodItem item) async {
    await _repository.addItem(item);
    await loadItems(); // Refresh the list
  }

  /// Update an existing item
  Future<void> updateItem(FoodItem item) async {
    await _repository.updateItem(item);
    await loadItems();
  }

  /// Delete an item
  Future<void> deleteItem(int id) async {
    await _repository.deleteItem(id);
    await loadItems();
  }

  /// Get items by location
  Future<List<FoodItem>> getItemsByLocation(Location location) async {
    return await _repository.getItemsByLocation(location);
  }

  /// Get items expiring soon
  Future<List<FoodItem>> getItemsExpiringSoon(int days) async {
    return await _repository.getItemsExpiringWithinDays(days);
  }
}

/// Provider for items expiring within 7 days
final expiringSoonProvider = FutureProvider<List<FoodItem>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return await repository.getItemsExpiringWithinDays(7);
});

/// Provider for total item count
final itemCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return await repository.getItemCount();
});
