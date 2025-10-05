import 'package:supabase_flutter/supabase_flutter.dart';
import '../../settings/models/household.dart';
import '../../../features/inventory/models/food_item.dart';

/// FOSS-compliant household sync using Supabase (open source Firebase alternative)
/// Users can use free Supabase cloud tier OR self-host their own instance!
class SupabaseHouseholdService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Check if user is authenticated with Supabase
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Create a new household in Supabase
  Future<Household> createHousehold(String name, String ownerName) async {
    // Ensure we're signed in anonymously
    await signInAnonymously();

    final household = Household(
      id: Household.generateCode(),
      name: name,
      ownerName: ownerName,
      createdAt: DateTime.now(),
      members: [ownerName],
    );

    await _client.from('households').insert({
      'id': household.id,
      'name': household.name,
      'owner_name': household.ownerName,
      'created_at': household.createdAt.toIso8601String(),
      'members': household.members,
    });

    print('✅ Household created: ${household.id}');
    return household;
  }

  /// Get household by ID
  Future<Household?> getHousehold(String householdId) async {
    // Ensure we're signed in anonymously
    await signInAnonymously();

    final response = await _client
        .from('households')
        .select()
        .eq('id', householdId)
        .single();

    if (response == null) return null;

    return Household(
      id: response['id'],
      name: response['name'],
      ownerName: response['owner_name'],
      createdAt: DateTime.parse(response['created_at']),
      members: List<String>.from(response['members']),
    );
  }

  /// Join an existing household
  Future<Household> joinHousehold(String householdId, String userName) async {
    // Ensure we're signed in anonymously
    await signInAnonymously();

    // Get current household
    final household = await getHousehold(householdId);
    if (household == null) {
      throw Exception('Household not found');
    }

    // Add user to members if not already there
    if (!household.members.contains(userName)) {
      final updatedMembers = [...household.members, userName];

      await _client.from('households').update({
        'members': updatedMembers,
      }).eq('id', householdId);

      print('✅ Joined household: $householdId');

      // Return updated household
      household.members = updatedMembers;
      return household;
    }

    return household;
  }

  /// Leave a household
  Future<void> leaveHousehold(String householdId, String userName) async {
    final household = await getHousehold(householdId);
    if (household == null) return;

    final updatedMembers = household.members.where((m) => m != userName).toList();

    await _client.from('households').update({
      'members': updatedMembers,
    }).eq('id', householdId);

    print('✅ Left household: $householdId');
  }

  /// Update household name
  Future<void> updateHouseholdName(String householdId, String newName) async {
    // Ensure we're signed in anonymously
    await signInAnonymously();

    await _client.from('households').update({
      'name': newName,
    }).eq('id', householdId);

    print('✅ Updated household name: $newName');
  }

  /// Add food item to household inventory
  Future<void> addFoodItem(String householdId, FoodItem item, String localKey) async {
    // Ensure we're signed in anonymously
    await signInAnonymously();

    await _client.from('food_items').insert({
      'household_id': householdId,
      'local_key': localKey,
      'name': item.name,
      'category': item.category,
      'barcode': item.barcode,
      'quantity': item.quantity,
      'unit': item.unit,
      'purchase_date': item.purchaseDate.toIso8601String(),
      'expiration_date': item.expirationDate.toIso8601String(),
      'notes': item.notes,
      'last_modified': item.lastModified?.toIso8601String() ?? DateTime.now().toIso8601String(),
    });

    print('✅ Synced item to Supabase: ${item.name}');
  }

  /// Update food item in household inventory
  Future<void> updateFoodItem(String householdId, FoodItem item, String localKey) async {
    await _client.from('food_items').update({
      'name': item.name,
      'category': item.category,
      'barcode': item.barcode,
      'quantity': item.quantity,
      'unit': item.unit,
      'purchase_date': item.purchaseDate.toIso8601String(),
      'expiration_date': item.expirationDate.toIso8601String(),
      'notes': item.notes,
      'last_modified': item.lastModified?.toIso8601String() ?? DateTime.now().toIso8601String(),
    }).eq('household_id', householdId).eq('local_key', localKey);

    print('✅ Updated item in Supabase: ${item.name}');
  }

  /// Delete food item from household inventory
  Future<void> deleteFoodItem(String householdId, String localKey) async {
    await _client
        .from('food_items')
        .delete()
        .eq('household_id', householdId)
        .eq('local_key', localKey);

    print('✅ Deleted item from Supabase');
  }

  /// Get all food items for a household
  Future<List<FoodItem>> getHouseholdItems(String householdId) async {
    final response = await _client
        .from('food_items')
        .select()
        .eq('household_id', householdId);

    return (response as List).map<FoodItem>((item) {
      final foodItem = FoodItem();
      foodItem.name = item['name'];
      foodItem.category = item['category'];
      foodItem.barcode = item['barcode'];
      foodItem.quantity = item['quantity'];
      foodItem.unit = item['unit'];
      foodItem.purchaseDate = DateTime.parse(item['purchase_date']);
      foodItem.expirationDate = DateTime.parse(item['expiration_date']);
      foodItem.notes = item['notes'];
      foodItem.lastModified = DateTime.parse(item['last_modified']);
      foodItem.householdId = item['household_id'];
      return foodItem;
    }).toList();
  }

  /// Subscribe to real-time updates for household items
  /// Returns a stream that emits whenever items change
  Stream<List<FoodItem>> subscribeToHouseholdItems(String householdId) {
    return _client
        .from('food_items')
        .stream(primaryKey: ['household_id', 'local_key'])
        .eq('household_id', householdId)
        .map((data) {
          return data.map<FoodItem>((item) {
            final foodItem = FoodItem();
            foodItem.name = item['name'];
            foodItem.category = item['category'];
            foodItem.barcode = item['barcode'];
            foodItem.quantity = item['quantity'];
            foodItem.unit = item['unit'];
            foodItem.purchaseDate = DateTime.parse(item['purchase_date']);
            foodItem.expirationDate = DateTime.parse(item['expiration_date']);
            foodItem.notes = item['notes'];
            foodItem.lastModified = DateTime.parse(item['last_modified']);
            foodItem.householdId = item['household_id'];
            return foodItem;
          }).toList();
        });
  }

  /// Sign in anonymously (no account needed!)
  /// This lets users sync without creating accounts
  Future<void> signInAnonymously() async {
    if (!isAuthenticated) {
      await _client.auth.signInAnonymously();
      print('✅ Signed in anonymously to Supabase');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
    print('✅ Signed out from Supabase');
  }
}
