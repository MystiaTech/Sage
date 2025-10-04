import 'dart:convert';
import 'package:http/http.dart' as http;

class BarcodeService {
  /// Lookup product info from barcode using multiple APIs
  static Future<ProductInfo?> lookupBarcode(String barcode) async {
    // Try Open Food Facts first (best for food)
    final openFoodResult = await _tryOpenFoodFacts(barcode);
    if (openFoodResult != null) return openFoodResult;

    // Try UPCItemDB (good for vitamins, supplements, general products)
    final upcItemDbResult = await _tryUPCItemDB(barcode);
    if (upcItemDbResult != null) return upcItemDbResult;

    return null;
  }

  /// Try Open Food Facts API
  static Future<ProductInfo?> _tryOpenFoodFacts(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 1) {
          final product = data['product'];

          return ProductInfo(
            name: product['product_name'] ?? 'Unknown Product',
            category: _extractCategory(product),
            imageUrl: product['image_url'],
          );
        }
      }
    } catch (e) {
      print('Open Food Facts error: $e');
    }
    return null;
  }

  /// Try UPCItemDB API (no key needed for limited requests)
  static Future<ProductInfo?> _tryUPCItemDB(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];

          return ProductInfo(
            name: item['title'] ?? 'Unknown Product',
            category: item['category'] ?? _guessCategoryFromTitle(item['title']),
            imageUrl: item['images']?[0],
          );
        }
      }
    } catch (e) {
      print('UPCItemDB error: $e');
    }
    return null;
  }

  /// Guess category from product title
  static String? _guessCategoryFromTitle(String? title) {
    if (title == null) return null;

    final titleLower = title.toLowerCase();

    if (titleLower.contains('vitamin') || titleLower.contains('supplement')) return 'Supplements';
    if (titleLower.contains('protein') || titleLower.contains('powder')) return 'Supplements';
    if (titleLower.contains('milk') || titleLower.contains('cheese')) return 'Dairy';
    if (titleLower.contains('sauce') || titleLower.contains('dressing')) return 'Condiments';
    if (titleLower.contains('drink') || titleLower.contains('beverage')) return 'Beverages';

    return null;
  }

  static String? _extractCategory(Map<String, dynamic> product) {
    // Try to get category from various fields
    if (product['categories'] != null && product['categories'].toString().isNotEmpty) {
      final categories = product['categories'].toString().split(',');
      if (categories.isNotEmpty) {
        return categories.first.trim();
      }
    }

    if (product['food_groups'] != null) {
      return product['food_groups'].toString();
    }

    return null;
  }

  /// Get smart expiration days based on category
  static int getSmartExpirationDays(String? category) {
    if (category == null) return 7; // Default 1 week

    final categoryLower = category.toLowerCase();

    // Dairy products
    if (categoryLower.contains('milk') ||
        categoryLower.contains('dairy') ||
        categoryLower.contains('yogurt') ||
        categoryLower.contains('cheese')) {
      return 7; // 1 week
    }

    // Meat and seafood
    if (categoryLower.contains('meat') ||
        categoryLower.contains('chicken') ||
        categoryLower.contains('beef') ||
        categoryLower.contains('pork') ||
        categoryLower.contains('fish') ||
        categoryLower.contains('seafood')) {
      return 3; // 3 days
    }

    // Produce
    if (categoryLower.contains('fruit') ||
        categoryLower.contains('vegetable') ||
        categoryLower.contains('produce')) {
      return 5; // 5 days
    }

    // Beverages
    if (categoryLower.contains('beverage') ||
        categoryLower.contains('drink') ||
        categoryLower.contains('juice') ||
        categoryLower.contains('soda')) {
      return 30; // 30 days
    }

    // Condiments and sauces
    if (categoryLower.contains('sauce') ||
        categoryLower.contains('condiment') ||
        categoryLower.contains('dressing') ||
        categoryLower.contains('ketchup') ||
        categoryLower.contains('mustard')) {
      return 90; // 3 months
    }

    // Canned/packaged goods
    if (categoryLower.contains('canned') ||
        categoryLower.contains('packaged') ||
        categoryLower.contains('snack')) {
      return 180; // 6 months
    }

    // Bread and bakery
    if (categoryLower.contains('bread') ||
        categoryLower.contains('bakery') ||
        categoryLower.contains('pastry')) {
      return 5; // 5 days
    }

    // Supplements and vitamins
    if (categoryLower.contains('supplement') ||
        categoryLower.contains('vitamin') ||
        categoryLower.contains('protein') ||
        categoryLower.contains('pill')) {
      return 365; // 1 year
    }

    return 7; // Default 1 week
  }
}

class ProductInfo {
  final String name;
  final String? category;
  final String? imageUrl;

  ProductInfo({
    required this.name,
    this.category,
    this.imageUrl,
  });
}
