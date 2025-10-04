import 'package:hive/hive.dart';
import '../../../data/local/hive_database.dart';
import '../../settings/models/app_settings.dart';
import '../../household/services/firebase_household_service.dart';
import '../models/food_item.dart';
import 'inventory_repository.dart';

/// Hive implementation of InventoryRepository with Firebase sync
class InventoryRepositoryImpl implements InventoryRepository {
  final _firebaseService = FirebaseHouseholdService();
  Future<Box<FoodItem>> get _box async => await HiveDatabase.getFoodBox();

  /// Get the current household ID from settings
  Future<String?> get _currentHouseholdId async {
    final settings = await HiveDatabase.getSettings();
    return settings.currentHouseholdId;
  }

  /// Filter items by current household
  /// If user is in a household, only show items from that household
  /// If user is not in a household, only show items without a household
  List<FoodItem> _filterByHousehold(Iterable<FoodItem> items, String? householdId) {
    return items.where((item) {
      if (householdId == null) {
        // User not in household - show items without household
        return item.householdId == null;
      } else {
        // User in household - show items from that household
        return item.householdId == householdId;
      }
    }).toList();
  }

  @override
  Future<List<FoodItem>> getAllItems() async {
    final box = await _box;
    final householdId = await _currentHouseholdId;
    return _filterByHousehold(box.values, householdId);
  }

  @override
  Future<FoodItem?> getItemById(int id) async {
    final box = await _box;
    return box.get(id);
  }

  @override
  Future<void> addItem(FoodItem item) async {
    final box = await _box;
    item.lastModified = DateTime.now();
    await box.add(item);

    print('📝 Added item to Hive: ${item.name}, key=${item.key}, householdId=${item.householdId}');

    // Sync to Firebase if in a household
    if (item.householdId != null && item.key != null) {
      print('🚀 Uploading item to Firebase: ${item.name} (key: ${item.key})');
      try {
        await _firebaseService.addFoodItem(
          item.householdId!,
          item,
          item.key.toString(),
        );
        print('✅ Successfully uploaded to Firebase');
      } catch (e) {
        print('❌ Failed to sync item to Firebase: $e');
      }
    } else {
      print('⚠️ Skipping Firebase sync: householdId=${item.householdId}, key=${item.key}');
    }
  }

  @override
  Future<void> updateItem(FoodItem item) async {
    item.lastModified = DateTime.now();
    await item.save();

    // Sync to Firebase if in a household
    if (item.householdId != null && item.key != null) {
      try {
        await _firebaseService.updateFoodItem(
          item.householdId!,
          item,
          item.key.toString(),
        );
      } catch (e) {
        print('Failed to sync item update to Firebase: $e');
      }
    }
  }

  @override
  Future<void> deleteItem(int id) async {
    final box = await _box;
    final item = box.get(id);

    // Sync deletion to Firebase if in a household
    if (item != null && item.householdId != null) {
      try {
        await _firebaseService.deleteFoodItem(
          item.householdId!,
          id.toString(),
        );
      } catch (e) {
        print('Failed to sync item deletion to Firebase: $e');
      }
    }

    await box.delete(id);
  }

  @override
  Future<List<FoodItem>> getItemsByLocation(Location location) async {
    final box = await _box;
    final householdId = await _currentHouseholdId;
    final filteredItems = _filterByHousehold(box.values, householdId);
    return filteredItems
        .where((item) => item.location == location)
        .toList();
  }

  @override
  Future<List<FoodItem>> getItemsExpiringWithinDays(int days) async {
    final box = await _box;
    final householdId = await _currentHouseholdId;
    final filteredItems = _filterByHousehold(box.values, householdId);
    final targetDate = DateTime.now().add(Duration(days: days));
    return filteredItems
        .where((item) =>
            item.expirationDate.isBefore(targetDate) &&
            item.expirationDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
  }

  @override
  Future<List<FoodItem>> getExpiredItems() async {
    final box = await _box;
    final householdId = await _currentHouseholdId;
    final filteredItems = _filterByHousehold(box.values, householdId);
    return filteredItems
        .where((item) => item.expirationDate.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
  }

  @override
  Future<List<FoodItem>> searchItemsByName(String query) async {
    final box = await _box;
    final householdId = await _currentHouseholdId;
    final filteredItems = _filterByHousehold(box.values, householdId);
    final lowerQuery = query.toLowerCase();
    return filteredItems
        .where((item) => item.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<int> getItemCount() async {
    final box = await _box;
    final householdId = await _currentHouseholdId;
    final filteredItems = _filterByHousehold(box.values, householdId);
    return filteredItems.length;
  }

  @override
  Stream<List<FoodItem>> watchAllItems() async* {
    final box = await _box;
    final householdId = await _currentHouseholdId;
    yield _filterByHousehold(box.values, householdId);

    await for (final _ in box.watch()) {
      final currentHouseholdId = await _currentHouseholdId;
      yield _filterByHousehold(box.values, currentHouseholdId);
    }
  }

  @override
  Stream<List<FoodItem>> watchExpiringItems(int days) async* {
    final box = await _box;
    final householdId = await _currentHouseholdId;
    final targetDate = DateTime.now().add(Duration(days: days));

    final filteredItems = _filterByHousehold(box.values, householdId);
    yield filteredItems
        .where((item) =>
            item.expirationDate.isBefore(targetDate) &&
            item.expirationDate.isAfter(DateTime.now()))
        .toList();

    await for (final _ in box.watch()) {
      final currentHouseholdId = await _currentHouseholdId;
      final currentFilteredItems = _filterByHousehold(box.values, currentHouseholdId);
      yield currentFilteredItems
          .where((item) =>
              item.expirationDate.isBefore(targetDate) &&
              item.expirationDate.isAfter(DateTime.now()))
          .toList();
    }
  }
}
