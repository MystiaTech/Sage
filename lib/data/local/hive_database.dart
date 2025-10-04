import 'package:hive_flutter/hive_flutter.dart';
import '../../features/inventory/models/food_item.dart';
import '../../features/settings/models/app_settings.dart';

/// Singleton class to manage Hive database
class HiveDatabase {
  static bool _initialized = false;

  /// Initialize Hive
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(FoodItemAdapter());
    Hive.registerAdapter(LocationAdapter());
    Hive.registerAdapter(ExpirationStatusAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    _initialized = true;
  }

  /// Get the food items box
  static Future<Box<FoodItem>> getFoodBox() async {
    if (!Hive.isBoxOpen('foodItems')) {
      return await Hive.openBox<FoodItem>('foodItems');
    }
    return Hive.box<FoodItem>('foodItems');
  }

  /// Get the settings box
  static Future<Box<AppSettings>> getSettingsBox() async {
    if (!Hive.isBoxOpen('appSettings')) {
      return await Hive.openBox<AppSettings>('appSettings');
    }
    return Hive.box<AppSettings>('appSettings');
  }

  /// Get or create app settings
  static Future<AppSettings> getSettings() async {
    final box = await getSettingsBox();
    if (box.isEmpty) {
      final settings = AppSettings();
      await box.add(settings);
      return settings;
    }
    return box.getAt(0)!;
  }

  /// Clear all data
  static Future<void> clearAll() async {
    final box = await getFoodBox();
    await box.clear();
  }

  /// Close all boxes
  static Future<void> closeAll() async {
    await Hive.close();
  }
}
