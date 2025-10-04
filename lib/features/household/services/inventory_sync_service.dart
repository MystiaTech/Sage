import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../data/local/hive_database.dart';
import '../../inventory/models/food_item.dart';

/// Service for syncing inventory items with Firebase in real-time
class InventorySyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _itemsSubscription;
  final _syncCallbacks = <VoidCallback>[];

  /// Register a callback to be called when sync occurs
  void addSyncCallback(VoidCallback callback) {
    _syncCallbacks.add(callback);
  }

  /// Remove a sync callback
  void removeSyncCallback(VoidCallback callback) {
    _syncCallbacks.remove(callback);
  }

  /// Start listening to household items from Firebase
  Future<void> startSync(String householdId) async {
    await stopSync(); // Stop any existing subscription

    print('📡 Starting Firebase sync for household: $householdId');

    _itemsSubscription = _firestore
        .collection('households')
        .doc(householdId)
        .collection('items')
        .snapshots()
        .listen((snapshot) async {
      print('🔄 Received ${snapshot.docs.length} items from Firebase');
      await _handleItemsUpdate(snapshot, householdId);

      // Notify listeners
      for (final callback in _syncCallbacks) {
        callback();
      }
    }, onError: (error) {
      print('❌ Firebase sync error: $error');
    });
  }

  /// Stop listening to Firebase updates
  Future<void> stopSync() async {
    await _itemsSubscription?.cancel();
    _itemsSubscription = null;
  }

  /// Handle updates from Firebase
  Future<void> _handleItemsUpdate(
    QuerySnapshot snapshot,
    String householdId,
  ) async {
    print('📦 Processing ${snapshot.docs.length} items from Firebase');
    final box = await HiveDatabase.getFoodBox();

    // Track Firebase item IDs
    final firebaseItemIds = <String>{};
    int newItems = 0;
    int updatedItems = 0;

    for (final doc in snapshot.docs) {
      firebaseItemIds.add(doc.id);
      final data = doc.data() as Map<String, dynamic>;

      // Check if item exists in local Hive
      final itemKey = int.tryParse(doc.id);
      if (itemKey != null) {
        final existingItem = box.get(itemKey);

        // Create or update item
        final item = _createFoodItemFromData(data, householdId);

        if (existingItem == null) {
          // New item from Firebase - add to local Hive with specific key
          await box.put(itemKey, item);
          newItems++;
          print('➕ Added new item from Firebase: ${item.name} (key: $itemKey)');
        } else {
          // Update existing item if Firebase version is newer
          final firebaseModified = DateTime.parse(data['lastModified'] as String);
          final localModified = existingItem.lastModified ?? DateTime(2000);

          if (firebaseModified.isAfter(localModified)) {
            // Firebase version is newer - update local
            await box.put(itemKey, item);
            updatedItems++;
            print('🔄 Updated item from Firebase: ${item.name} (key: $itemKey)');
          }
        }
      }
    }

    print('📊 Sync stats: $newItems new, $updatedItems updated');

    // Delete items that no longer exist in Firebase
    final itemsToDelete = <int>[];
    for (final item in box.values) {
      if (item.householdId == householdId && item.key != null) {
        if (!firebaseItemIds.contains(item.key.toString())) {
          itemsToDelete.add(item.key!);
        }
      }
    }

    if (itemsToDelete.isNotEmpty) {
      print('🗑️ Deleting ${itemsToDelete.length} items that no longer exist in Firebase');
      for (final key in itemsToDelete) {
        await box.delete(key);
      }
    }
  }

  /// Create FoodItem from Firebase data
  FoodItem _createFoodItemFromData(Map<String, dynamic> data, String householdId) {
    return FoodItem()
      ..name = data['name'] as String
      ..barcode = data['barcode'] as String?
      ..quantity = data['quantity'] as int
      ..unit = data['unit'] as String?
      ..purchaseDate = DateTime.parse(data['purchaseDate'] as String)
      ..expirationDate = DateTime.parse(data['expirationDate'] as String)
      ..locationIndex = data['locationIndex'] as int
      ..category = data['category'] as String?
      ..photoUrl = data['photoUrl'] as String?
      ..notes = data['notes'] as String?
      ..userId = data['userId'] as String?
      ..householdId = householdId
      ..lastModified = DateTime.parse(data['lastModified'] as String)
      ..syncedToCloud = true;
  }
}
