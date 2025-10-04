import '../models/food_item.dart';

/// Repository interface for inventory operations
/// This defines the contract for inventory data access
abstract class InventoryRepository {
  /// Get all items in inventory
  Future<List<FoodItem>> getAllItems();

  /// Get a single item by ID
  Future<FoodItem?> getItemById(int id);

  /// Add a new item to inventory
  Future<void> addItem(FoodItem item);

  /// Update an existing item
  Future<void> updateItem(FoodItem item);

  /// Delete an item
  Future<void> deleteItem(int id);

  /// Get items by location
  Future<List<FoodItem>> getItemsByLocation(Location location);

  /// Get items expiring within X days
  Future<List<FoodItem>> getItemsExpiringWithinDays(int days);

  /// Get all expired items
  Future<List<FoodItem>> getExpiredItems();

  /// Search items by name
  Future<List<FoodItem>> searchItemsByName(String query);

  /// Get count of all items
  Future<int> getItemCount();

  /// Watch all items (stream for real-time updates)
  Stream<List<FoodItem>> watchAllItems();

  /// Watch items expiring soon
  Stream<List<FoodItem>> watchExpiringItems(int days);
}
