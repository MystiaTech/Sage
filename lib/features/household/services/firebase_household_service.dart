import 'package:cloud_firestore/cloud_firestore.dart';
import '../../settings/models/household.dart';
import '../../../features/inventory/models/food_item.dart';

/// Service for managing household data in Firestore
class FirebaseHouseholdService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new household in Firestore
  Future<Household> createHousehold(String name, String ownerName) async {
    final household = Household(
      id: Household.generateCode(),
      name: name,
      ownerName: ownerName,
      createdAt: DateTime.now(),
      members: [ownerName],
    );

    await _firestore.collection('households').doc(household.id).set({
      'id': household.id,
      'name': household.name,
      'ownerName': household.ownerName,
      'createdAt': household.createdAt.toIso8601String(),
      'members': household.members,
    });

    return household;
  }

  /// Get household by code from Firestore
  Future<Household?> getHousehold(String code) async {
    try {
      final doc = await _firestore.collection('households').doc(code).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      final household = Household(
        id: data['id'] as String,
        name: data['name'] as String,
        ownerName: data['ownerName'] as String,
        createdAt: DateTime.parse(data['createdAt'] as String),
        members: List<String>.from(data['members'] as List),
      );

      return household;
    } catch (e) {
      return null;
    }
  }

  /// Join a household (add member)
  Future<bool> joinHousehold(String code, String memberName) async {
    try {
      final docRef = _firestore.collection('households').doc(code);
      final doc = await docRef.get();

      if (!doc.exists) {
        return false;
      }

      final members = List<String>.from(doc.data()!['members'] as List);
      if (!members.contains(memberName)) {
        members.add(memberName);
        await docRef.update({'members': members});
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Leave a household (remove member)
  Future<void> leaveHousehold(String code, String memberName) async {
    final docRef = _firestore.collection('households').doc(code);
    final doc = await docRef.get();

    if (doc.exists) {
      final members = List<String>.from(doc.data()!['members'] as List);
      members.remove(memberName);

      if (members.isEmpty) {
        // Delete household if no members left
        await docRef.delete();
      } else {
        await docRef.update({'members': members});
      }
    }
  }

  /// Add food item to household in Firestore
  Future<void> addFoodItem(String householdId, FoodItem item, String itemKey) async {
    await _firestore
        .collection('households')
        .doc(householdId)
        .collection('items')
        .doc(itemKey.toString())
        .set({
      'name': item.name,
      'barcode': item.barcode,
      'quantity': item.quantity,
      'unit': item.unit,
      'purchaseDate': item.purchaseDate.toIso8601String(),
      'expirationDate': item.expirationDate.toIso8601String(),
      'locationIndex': item.locationIndex,
      'category': item.category,
      'photoUrl': item.photoUrl,
      'notes': item.notes,
      'userId': item.userId,
      'householdId': item.householdId,
      'lastModified': item.lastModified?.toIso8601String(),
      'syncedToCloud': true,
    });
  }

  /// Update food item in Firestore
  Future<void> updateFoodItem(String householdId, FoodItem item, String itemKey) async {
    await _firestore
        .collection('households')
        .doc(householdId)
        .collection('items')
        .doc(itemKey.toString())
        .update({
      'name': item.name,
      'barcode': item.barcode,
      'quantity': item.quantity,
      'unit': item.unit,
      'purchaseDate': item.purchaseDate.toIso8601String(),
      'expirationDate': item.expirationDate.toIso8601String(),
      'locationIndex': item.locationIndex,
      'category': item.category,
      'photoUrl': item.photoUrl,
      'notes': item.notes,
      'lastModified': DateTime.now().toIso8601String(),
    });
  }

  /// Delete food item from Firestore
  Future<void> deleteFoodItem(String householdId, String itemKey) async {
    await _firestore
        .collection('households')
        .doc(householdId)
        .collection('items')
        .doc(itemKey.toString())
        .delete();
  }

  /// Stream household items from Firestore
  Stream<List<Map<String, dynamic>>> streamHouseholdItems(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('items')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['firestoreId'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Sync local items to Firestore
  Future<void> syncItemsToFirestore(String householdId, List<FoodItem> items) async {
    final batch = _firestore.batch();
    final collection = _firestore
        .collection('households')
        .doc(householdId)
        .collection('items');

    for (final item in items) {
      if (item.householdId == householdId && item.key != null) {
        final docRef = collection.doc(item.key.toString());
        batch.set(docRef, {
          'name': item.name,
          'barcode': item.barcode,
          'quantity': item.quantity,
          'unit': item.unit,
          'purchaseDate': item.purchaseDate.toIso8601String(),
          'expirationDate': item.expirationDate.toIso8601String(),
          'locationIndex': item.locationIndex,
          'category': item.category,
          'photoUrl': item.photoUrl,
          'notes': item.notes,
          'userId': item.userId,
          'householdId': item.householdId,
          'lastModified': item.lastModified?.toIso8601String(),
          'syncedToCloud': true,
        });
      }
    }

    await batch.commit();
  }
}
