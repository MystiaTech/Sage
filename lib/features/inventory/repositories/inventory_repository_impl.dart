import 'package:hive/hive.dart';
import '../../../data/local/hive_database.dart';
import '../models/food_item.dart';
import 'inventory_repository.dart';

/// Hive implementation of InventoryRepository
class InventoryRepositoryImpl implements InventoryRepository {
  Future<Box<FoodItem>> get _box async => await HiveDatabase.getFoodBox();

  @override
  Future<List<FoodItem>> getAllItems() async {
    final box = await _box;
    return box.values.toList();
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
  }

  @override
  Future<void> updateItem(FoodItem item) async {
    item.lastModified = DateTime.now();
    await item.save();
  }

  @override
  Future<void> deleteItem(int id) async {
    final box = await _box;
    await box.delete(id);
  }

  @override
  Future<List<FoodItem>> getItemsByLocation(Location location) async {
    final box = await _box;
    return box.values
        .where((item) => item.location == location)
        .toList();
  }

  @override
  Future<List<FoodItem>> getItemsExpiringWithinDays(int days) async {
    final box = await _box;
    final targetDate = DateTime.now().add(Duration(days: days));
    return box.values
        .where((item) =>
            item.expirationDate.isBefore(targetDate) &&
            item.expirationDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
  }

  @override
  Future<List<FoodItem>> getExpiredItems() async {
    final box = await _box;
    return box.values
        .where((item) => item.expirationDate.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
  }

  @override
  Future<List<FoodItem>> searchItemsByName(String query) async {
    final box = await _box;
    final lowerQuery = query.toLowerCase();
    return box.values
        .where((item) => item.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<int> getItemCount() async {
    final box = await _box;
    return box.length;
  }

  @override
  Stream<List<FoodItem>> watchAllItems() async* {
    final box = await _box;
    yield box.values.toList();

    await for (final _ in box.watch()) {
      yield box.values.toList();
    }
  }

  @override
  Stream<List<FoodItem>> watchExpiringItems(int days) async* {
    final box = await _box;
    final targetDate = DateTime.now().add(Duration(days: days));

    yield box.values
        .where((item) =>
            item.expirationDate.isBefore(targetDate) &&
            item.expirationDate.isAfter(DateTime.now()))
        .toList();

    await for (final _ in box.watch()) {
      yield box.values
          .where((item) =>
              item.expirationDate.isBefore(targetDate) &&
              item.expirationDate.isAfter(DateTime.now()))
          .toList();
    }
  }
}
