import 'package:hive/hive.dart';

part 'food_item.g.dart';

/// Represents a food item in the inventory
@HiveType(typeId: 0)
class FoodItem extends HiveObject {
  // Basic Info
  @HiveField(0)
  late String name;

  @HiveField(1)
  String? barcode;

  @HiveField(2)
  late int quantity;

  @HiveField(3)
  String? unit; // "bottles", "lbs", "oz", "items"

  // Dates
  @HiveField(4)
  late DateTime purchaseDate;

  @HiveField(5)
  late DateTime expirationDate;

  // Organization
  @HiveField(6)
  late int locationIndex; // Store as int for Hive

  @HiveField(7)
  String? category; // Auto from barcode or manual

  // Media & Notes
  @HiveField(8)
  String? photoUrl; // Cached from API or user uploaded

  @HiveField(9)
  String? notes;

  // Multi-user support (for future phases)
  @HiveField(10)
  String? userId;

  @HiveField(11)
  String? householdId;

  // Sync tracking
  @HiveField(12)
  DateTime? lastModified;

  @HiveField(13)
  bool syncedToCloud = false;

  // Computed properties
  Location get location => Location.values[locationIndex];
  set location(Location loc) => locationIndex = loc.index;

  int get daysUntilExpiration {
    return expirationDate.difference(DateTime.now()).inDays;
  }

  ExpirationStatus get expirationStatus {
    final days = daysUntilExpiration;
    if (days < 0) return ExpirationStatus.expired;
    if (days <= 3) return ExpirationStatus.critical;
    if (days <= 7) return ExpirationStatus.warning;
    if (days <= 14) return ExpirationStatus.caution;
    return ExpirationStatus.fresh;
  }

  bool get isExpired => daysUntilExpiration < 0;

  bool get isExpiringSoon => daysUntilExpiration <= 7 && daysUntilExpiration >= 0;
}

/// Location where food is stored
@HiveType(typeId: 1)
enum Location {
  @HiveField(0)
  fridge,
  @HiveField(1)
  freezer,
  @HiveField(2)
  pantry,
  @HiveField(3)
  spiceRack,
  @HiveField(4)
  countertop,
  @HiveField(5)
  other,
}

/// Expiration status based on days until expiration
@HiveType(typeId: 2)
enum ExpirationStatus {
  @HiveField(0)
  fresh, // > 14 days
  @HiveField(1)
  caution, // 8-14 days
  @HiveField(2)
  warning, // 4-7 days
  @HiveField(3)
  critical, // 1-3 days
  @HiveField(4)
  expired, // 0 or negative days
}

// Extension to get user-friendly names for Location
extension LocationExtension on Location {
  String get displayName {
    switch (this) {
      case Location.fridge:
        return 'Fridge';
      case Location.freezer:
        return 'Freezer';
      case Location.pantry:
        return 'Pantry';
      case Location.spiceRack:
        return 'Spice Rack';
      case Location.countertop:
        return 'Countertop';
      case Location.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case Location.fridge:
        return '🧊';
      case Location.freezer:
        return '❄️';
      case Location.pantry:
        return '🗄️';
      case Location.spiceRack:
        return '🧂';
      case Location.countertop:
        return '🪴';
      case Location.other:
        return '📦';
    }
  }
}

// Extension for ExpirationStatus
extension ExpirationStatusExtension on ExpirationStatus {
  String get displayName {
    switch (this) {
      case ExpirationStatus.fresh:
        return 'Fresh';
      case ExpirationStatus.caution:
        return 'Use within 2 weeks';
      case ExpirationStatus.warning:
        return 'Use soon';
      case ExpirationStatus.critical:
        return 'Use now!';
      case ExpirationStatus.expired:
        return 'Expired';
    }
  }

  int get colorValue {
    switch (this) {
      case ExpirationStatus.fresh:
        return 0xFF4CAF50; // Green
      case ExpirationStatus.caution:
        return 0xFFFFEB3B; // Yellow
      case ExpirationStatus.warning:
        return 0xFFFF9800; // Orange
      case ExpirationStatus.critical:
        return 0xFFF44336; // Red
      case ExpirationStatus.expired:
        return 0xFF9E9E9E; // Gray
    }
  }
}
