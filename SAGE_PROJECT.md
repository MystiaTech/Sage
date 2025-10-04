# SAGE - COMPLETE PROJECT DOCUMENTATION
## Smart Kitchen Management System 🌿

**Version:** 1.0.0  
**Created:** October 3, 2025  
**Platform:** Flutter (Android & iOS)  
**Status:** Active Development 🔥

---

## 📖 TABLE OF CONTENTS

1. [Project Overview](#project-overview)
2. [Core Features](#core-features)
3. [Technical Architecture](#technical-architecture)
4. [Data Models](#data-models)
5. [API Integrations](#api-integrations)
6. [User Flows](#user-flows)
7. [Notification System](#notification-system)
8. [Multi-User & Sync](#multi-user--sync)
9. [Security & Privacy](#security--privacy)
10. [Testing Strategy](#testing-strategy)
11. [Deployment](#deployment)

---

## 📱 PROJECT OVERVIEW

### The Problem
- People forget what's in their fridge/pantry
- Food expires and gets wasted → money wasted
- Constant grocery store trips forgetting items
- End up ordering takeout when food at home expires
- No organization = kitchen chaos

### The Solution: SAGE
A comprehensive kitchen management app that:
1. **Tracks** all your food inventory with expiration dates
2. **Alerts** you before food expires (with Discord integration!)
3. **Manages** your recipes and connects them to inventory
4. **Generates** smart shopping lists
5. **Shares** with household members
6. **Works offline-first** with optional cloud sync

### Why "Sage"?
- 🌿 The herb (kitchen theme)
- 🧠 Wisdom and smart decisions
- 💚 Simple, clean, memorable

### Target Users
- Busy individuals who want to save money
- Families managing shared kitchens
- Anyone tired of wasting food
- People who hate grocery shopping inefficiency
- Budget-conscious cooks

---

## 🎯 CORE FEATURES

### 1. INVENTORY TRACKER 📦

**The Foundation:** Track everything in your kitchen

**Key Capabilities:**
- Add items via barcode scan OR manual entry
- Auto-populate from Open Food Facts (2M+ products!)
- Track quantity, expiration date, location
- Organize by location (fridge, freezer, pantry, etc.)
- Categorize automatically or manually
- Attach photos (cached locally)
- Search and filter inventory
- Quick edit/delete items

**Barcode Scanning:**
```
User scans barcode
    ↓
Query Open Food Facts API
    ↓
Product found?
    ├─ YES → Auto-fill: name, photo, category, typical shelf life
    │         User adds: quantity, actual expiration, location
    │         → Save to local database
    │
    └─ NO → Manual entry form
             User fills everything
             → Save to local database
```

**Data Tracked Per Item:**
- Name
- Barcode (if scanned)
- Quantity & unit
- Purchase date
- Expiration date
- Location (fridge/freezer/pantry/other)
- Category (auto or manual)
- Photo URL (cached)
- Notes (optional)
- Last modified timestamp
- Sync status

---

### 2. SMART ALERTS 🔔

**The Brain:** Never let food go to waste

**Alert Timeline:**

| Time Before Expiration | Alert Type | Message |
|------------------------|------------|---------|
| 1 month | FYI notification | "Ranch dressing expires in 30 days" |
| 2 weeks | Heads up | "Sour cream expires in 14 days" |
| 1 week | Use soon! | "Milk expires in 7 days - Tap for recipes" |
| Before next shopping day | Shopping alert | "3 items expire before next week!" |

**Shopping Day Intelligence:**
```
User sets shopping frequency:
  - Weekly (every Tuesday)
  - Bi-weekly (every other Monday)
  - Monthly (first Saturday)
  - Pay cycle (15th and 30th)
  - Custom days

System calculates next shopping day
    ↓
For each item expiring before next shopping day:
    → Send notification
    → Add to "Add to Shopping List" quick action
    → Send to Discord channel (if enabled)
```

**Notification Types:**
1. **Local Push Notifications**
   - Scheduled in advance
   - Tappable (opens relevant screen)
   - Customizable (can disable certain types)

2. **Discord Webhooks**
   - Critical alerts only (shopping day, urgent expirations)
   - Formatted with emojis and priority
   - @everyone tag for household

**Example Discord Message:**
```markdown
🌿 **Sage Alert** 🌿
@everyone Shopping day is tomorrow!

**Expiring before next week:**
🔴 Ranch dressing (expires Oct 10) - 3 days
🔴 Croutons (expires Oct 12) - 5 days
🟡 Milk (expires Oct 15) - 8 days

**Suggested Actions:**
• Add to shopping list
• Check "Use It Up" recipes
• Update quantities if already replaced

Don't forget to restock! 🛒
```

---

### 3. RECIPE BOOK 📖

**The Inspiration:** Never wonder "what's for dinner?" again

**Core Functions:**
- Add recipes manually or copy/paste from websites
- Store ingredients with quantities
- Write/paste instructions
- Add optional photos
- Tag recipes (Quick, Vegetarian, Fancy, etc.)
- Share recipes with community (optional)
- Mark favorites

**Smart Features:**
- **"What Can I Make?"** - Shows recipes you can make with current inventory
  - Displays % of ingredients you have
  - Sorts by completeness
  - Shows what's missing
  
- **"Use It Up!"** - Suggests recipes using expiring items
  - Prioritizes items expiring soonest
  - Helps prevent waste

**Recipe Data Structure:**
```dart
Recipe {
  name: "Caesar Salad"
  ingredients: [
    {name: "Romaine lettuce", quantity: 1, unit: "head"},
    {name: "Caesar dressing", quantity: 0.5, unit: "cup"},
    {name: "Croutons", quantity: 1, unit: "cup"},
    {name: "Parmesan", quantity: 0.25, unit: "cup", optional: true}
  ]
  instructions: "Chop lettuce. Toss with dressing. Top with croutons and parmesan."
  prepTime: 10 minutes
  servings: 2
  tags: ["Quick", "Salad", "Vegetarian"]
  photo: "url_or_local_path"
  isPublic: true  // Share with community
  createdBy: user_id
}
```

**Copy/Paste from Websites:**
User pastes URL or text block → Parser extracts:
- Recipe title
- Ingredient list (with quantities)
- Instructions
- Optional: photo, prep time, servings

Common formats supported:
- Recipe schema (schema.org/Recipe)
- Plain text with smart parsing
- Popular recipe sites (AllRecipes, Food Network, etc.)

---

### 4. SHOPPING LISTS 🛒

**The Planner:** Efficient grocery trips, every time

**Key Features:**
- **Multiple Lists** - Separate lists for different stores
  - "Costco"
  - "Trader Joe's"
  - "Farmers Market"
  - Custom names
  
- **Smart List Building**
  - Add items manually
  - One-click add from recipes
  - Suggested items based on expiring inventory
  
- **While Shopping**
  - Check off items as you shop
  - Uncheck if needed
  - Sort by store section (optional)
  - Quick quantity adjust
  
- **After Shopping**
  - "Add All to Inventory" quick action
  - Batch-add checked items
  - Auto-populate likely expiration dates
  - Clear completed items

**Sharing:**
- Share lists with household members
- Real-time updates (if cloud sync enabled)
- See who added what
- Collaborative shopping

**List Organization:**
```
Shopping List: "Costco"
  Items:
    ☐ Milk (2 gallons) - Added from: Ranch expires alert
    ☑ Chicken breast (2 lbs) - Added from: Recipe "Chicken Tacos"
    ☐ Romaine lettuce (2 heads) - Added manually
    ☐ Croutons (1 bag) - Added from: Recipe "Caesar Salad"
    
  Quick Actions:
    - Add recipe ingredients
    - Add expiring items
    - Share list
    - Sort by aisle
```

---

### 5. MULTI-USER & SYNC ☁️

**The Connector:** Share with your household

**Three Sync Modes (User's Choice):**

#### Mode 1: Cloud Sync (Supabase) ☁️
**Best for:** Most users, easy setup, reliable

**Features:**
- Real-time sync across devices
- User authentication
- Household groups (shared inventory/lists)
- Recipe community sharing
- Automatic backups

**Technical:**
- PostgreSQL database (Supabase)
- Row-level security
- Real-time subscriptions
- Free tier: 500MB DB, 2GB bandwidth/month

**User Flow:**
```
Sign up with email
    ↓
Create or join household
    ↓
All devices sync automatically
    ↓
Changes propagate in real-time
```

#### Mode 2: Completely Free (Self-Hosted) 🏠
**Best for:** Privacy-conscious users, no cloud dependency

**Options:**

**A. Export/Import**
- Export inventory/recipes to JSON
- Share file via any method (email, cloud storage, etc.)
- Import on other device
- Manual sync process

**B. Local WiFi Sync**
- Devices on same network
- Peer-to-peer sync (no internet needed!)
- Automatic discovery
- One device = "host"

**C. Self-Host Backend**
- Docker Compose setup (we provide!)
- Run on Raspberry Pi or home server
- Full control of data
- Zero recurring costs

**Self-Hosted Setup:**
```bash
# We provide this in docs!
git clone https://github.com/sage-app/backend
cd backend
docker-compose up -d

# Configure app to point to your server
# http://192.168.1.100:3000
```

#### Mode 3: Local Only 📱
**Best for:** Solo users, maximum privacy, no sharing needed

**Features:**
- Everything on device
- Zero external dependencies
- Export for backup
- Fast and simple

**Offline-First Philosophy (ALL MODES):**
```
Every action saves locally FIRST
    ↓
If online & sync enabled:
    Queue for sync
    ↓
    Sync when possible
    ↓
    Update local cache

App works PERFECTLY offline
Never wait for network
Graceful sync when available
```

**Conflict Resolution:**
- Last-write-wins (timestamp-based)
- Show notification if conflict detected
- User can view both versions and choose

---

## 🏗️ TECHNICAL ARCHITECTURE

### Tech Stack Overview

```
┌─────────────────────────────────────┐
│         FLUTTER APP (Dart)          │
│  ┌───────────────────────────────┐  │
│  │    UI Layer (Widgets)         │  │
│  └──────────┬────────────────────┘  │
│             │                        │
│  ┌──────────▼────────────────────┐  │
│  │  State Management (Riverpod)  │  │
│  └──────────┬────────────────────┘  │
│             │                        │
│  ┌──────────▼────────────────────┐  │
│  │    Business Logic Layer       │  │
│  │  - Controllers                │  │
│  │  - Services                   │  │
│  │  - Repositories               │  │
│  └──────────┬────────────────────┘  │
│             │                        │
│  ┌──────────▼────────────────────┐  │
│  │      Data Layer               │  │
│  │  ┌──────────┐  ┌────────────┐ │  │
│  │  │   Isar   │  │ Supabase   │ │  │
│  │  │  (Local) │  │  (Cloud)   │ │  │
│  │  └──────────┘  └────────────┘ │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
            │
            ▼
   ┌────────────────────┐
   │  External APIs     │
   │  - Open Food Facts │
   │  - Discord Webhook │
   └────────────────────┘
```

### Key Technologies

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Framework | Flutter 3.x | Cross-platform UI |
| Language | Dart 3.x | Type-safe, fast, AOT compiled |
| State Management | Riverpod 2.x | Reactive state, dependency injection |
| Local Database | Isar 3.x | Fast NoSQL, offline-first |
| Cloud Database | Supabase | PostgreSQL, real-time, auth |
| Barcode Scanner | mobile_scanner | Camera-based scanning |
| Notifications | flutter_local_notifications | Scheduled alerts |
| Image Caching | cached_network_image | Performance optimization |
| HTTP Client | http | API requests |

### Project Structure

```
sage/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # App widget, theme, routing
│   │
│   ├── core/                        # Core utilities
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── api_constants.dart
│   │   │   └── colors.dart
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── validators.dart
│   │   │   └── formatters.dart
│   │   └── extensions/
│   │       ├── date_extensions.dart
│   │       └── string_extensions.dart
│   │
│   ├── features/                    # Feature modules
│   │   ├── inventory/
│   │   │   ├── models/
│   │   │   │   └── food_item.dart
│   │   │   ├── repositories/
│   │   │   │   └── inventory_repository.dart
│   │   │   ├── controllers/
│   │   │   │   └── inventory_controller.dart
│   │   │   ├── screens/
│   │   │   │   ├── inventory_screen.dart
│   │   │   │   ├── add_item_screen.dart
│   │   │   │   └── item_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── inventory_list.dart
│   │   │       ├── expiration_badge.dart
│   │   │       └── barcode_scanner.dart
│   │   │
│   │   ├── recipes/
│   │   │   ├── models/
│   │   │   │   └── recipe.dart
│   │   │   ├── repositories/
│   │   │   │   └── recipe_repository.dart
│   │   │   ├── controllers/
│   │   │   │   └── recipe_controller.dart
│   │   │   ├── screens/
│   │   │   │   ├── recipes_screen.dart
│   │   │   │   ├── add_recipe_screen.dart
│   │   │   │   ├── recipe_detail_screen.dart
│   │   │   │   └── what_can_i_make_screen.dart
│   │   │   └── widgets/
│   │   │       ├── recipe_card.dart
│   │   │       └── ingredient_list.dart
│   │   │
│   │   ├── shopping/
│   │   │   ├── models/
│   │   │   │   └── shopping_list.dart
│   │   │   ├── repositories/
│   │   │   │   └── shopping_repository.dart
│   │   │   ├── controllers/
│   │   │   │   └── shopping_controller.dart
│   │   │   ├── screens/
│   │   │   │   ├── shopping_lists_screen.dart
│   │   │   │   └── list_detail_screen.dart
│   │   │   └── widgets/
│   │   │       └── shopping_item.dart
│   │   │
│   │   ├── home/
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── expiring_soon_carousel.dart
│   │   │       └── quick_stats.dart
│   │   │
│   │   ├── settings/
│   │   │   ├── models/
│   │   │   │   └── user_settings.dart
│   │   │   ├── repositories/
│   │   │   │   └── settings_repository.dart
│   │   │   ├── controllers/
│   │   │   │   └── settings_controller.dart
│   │   │   └── screens/
│   │   │       ├── settings_screen.dart
│   │   │       ├── notifications_settings.dart
│   │   │       ├── sync_settings.dart
│   │   │       └── discord_settings.dart
│   │   │
│   │   └── auth/
│   │       ├── controllers/
│   │       │   └── auth_controller.dart
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           └── signup_screen.dart
│   │
│   ├── services/                    # Business logic services
│   │   ├── notification_service.dart
│   │   ├── sync_service.dart
│   │   ├── barcode_service.dart
│   │   ├── discord_service.dart
│   │   ├── openfoodfacts_service.dart
│   │   └── expiration_tracker_service.dart
│   │
│   ├── data/                        # Data layer
│   │   ├── local/
│   │   │   └── isar_database.dart
│   │   └── remote/
│   │       └── supabase_client.dart
│   │
│   └── shared/                      # Shared widgets & components
│       ├── widgets/
│       │   ├── custom_button.dart
│       │   ├── custom_text_field.dart
│       │   └── loading_indicator.dart
│       └── navigation/
│           └── app_router.dart
│
├── assets/                          # Static assets
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── test/                            # Tests
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── android/                         # Android-specific
├── ios/                            # iOS-specific
├── pubspec.yaml                    # Dependencies
└── README.md
```

---

## 💾 DATA MODELS (DETAILED)

### FoodItem Model

```dart
import 'package:isar/isar.dart';

part 'food_item.g.dart';

@collection
class FoodItem {
  Id id = Isar.autoIncrement;
  
  // Basic Info
  late String name;
  String? barcode;
  late int quantity;
  String? unit;  // "bottles", "lbs", "oz", "items"
  
  // Dates
  late DateTime purchaseDate;
  late DateTime expirationDate;
  
  // Organization
  @enumerated
  late Location location;
  String? category;  // Auto from barcode or manual
  
  // Media & Notes
  String? photoUrl;  // Cached from API or user uploaded
  String? notes;
  
  // Multi-user support
  String? userId;
  String? householdId;
  
  // Sync tracking
  DateTime? lastModified;
  bool syncedToCloud = false;
  
  // Computed properties (not stored)
  @ignore
  int get daysUntilExpiration {
    return expirationDate.difference(DateTime.now()).inDays;
  }
  
  @ignore
  ExpirationStatus get expirationStatus {
    final days = daysUntilExpiration;
    if (days < 0) return ExpirationStatus.expired;
    if (days <= 3) return ExpirationStatus.critical;
    if (days <= 7) return ExpirationStatus.warning;
    if (days <= 14) return ExpirationStatus.caution;
    return ExpirationStatus.fresh;
  }
}

enum Location {
  fridge,
  freezer,
  pantry,
  spiceRack,
  countertop,
  other
}

enum ExpirationStatus {
  fresh,      // > 14 days
  caution,    // 8-14 days
  warning,    // 4-7 days
  critical,   // 1-3 days
  expired     // 0 or negative days
}
```

### Recipe Model

```dart
import 'package:isar/isar.dart';

part 'recipe.g.dart';

@collection
class Recipe {
  Id id = Isar.autoIncrement;
  
  // Basic Info
  late String name;
  late String instructions;
  
  // Ingredients (embedded objects)
  late List<Ingredient> ingredients;
  
  // Media
  String? photoUrl;
  
  // Metadata
  List<String> tags = [];
  int? prepTimeMinutes;
  int? cookTimeMinutes;
  int? servings;
  
  @enumerated
  DifficultyLevel? difficulty;
  
  // Sharing
  String? createdBy;  // user_id
  bool isPublic = false;
  bool isFavorite = false;
  
  // Timestamps
  DateTime? created;
  DateTime? lastModified;
  
  // Sync
  bool syncedToCloud = false;
  
  // Computed
  @ignore
  int get totalTimeMinutes {
    return (prepTimeMinutes ?? 0) + (cookTimeMinutes ?? 0);
  }
}

@embedded
class Ingredient {
  late String name;
  double? quantity;
  String? unit;
  bool optional = false;
  
  // For matching against inventory
  String? matchedItemId;  // Link to FoodItem
}

enum DifficultyLevel {
  easy,
  medium,
  hard
}
```

### ShoppingList Model

```dart
import 'package:isar/isar.dart';

part 'shopping_list.g.dart';

@collection
class ShoppingList {
  Id id = Isar.autoIncrement;
  
  late String name;  // "Costco", "Trader Joe's"
  
  List<ShoppingItem> items = [];
  
  // Sharing
  String? householdId;
  List<String> sharedWith = [];
  
  // Metadata
  DateTime? created;
  DateTime? lastModified;
  
  // Sync
  bool syncedToCloud = false;
  
  // Computed
  @ignore
  int get totalItems => items.length;
  
  @ignore
  int get checkedItems => items.where((i) => i.checked).length;
  
  @ignore
  double get completionPercentage {
    if (totalItems == 0) return 0;
    return (checkedItems / totalItems) * 100;
  }
}

@embedded
class ShoppingItem {
  late String name;
  double? quantity;
  String? unit;
  bool checked = false;
  
  // Metadata
  @enumerated
  Priority priority = Priority.normal;
  
  String? addedFrom;  // "recipe:123", "inventory:456", "manual"
  String? addedBy;    // user_id
  DateTime? addedAt;
  
  String? notes;
}

enum Priority {
  low,
  normal,
  high
}
```

### UserSettings Model

```dart
import 'package:isar/isar.dart';

part 'user_settings.g.dart';

@collection
class UserSettings {
  Id id = Isar.autoIncrement;
  
  // Shopping Schedule
  @enumerated
  ShoppingFrequency frequency = ShoppingFrequency.weekly;
  
  // For weekly/biweekly
  int? dayOfWeek;  // 1-7 (Monday-Sunday)
  
  // For monthly
  int? dayOfMonth;  // 1-31
  
  // For pay cycle
  List<int>? payCycleDays;  // [15, 30]
  
  // For custom
  List<int>? customDays;  // [1, 4, 6] = Mon, Thu, Sat
  
  // Calculated
  DateTime? nextShoppingDay;
  
  // Notifications
  bool enableNotifications = true;
  bool notify1Month = true;
  bool notify2Weeks = true;
  bool notify1Week = true;
  bool notifyShoppingDay = true;
  
  // Discord
  bool enableDiscord = false;
  String? discordWebhookUrl;
  bool discordCriticalOnly = true;
  
  // Sync
  @enumerated
  SyncMode syncMode = SyncMode.localOnly;
  
  String? supabaseUserId;
  String? householdId;
  
  // Display
  bool showPhotos = true;
  bool showExpirationBadges = true;
  
  @enumerated
  ThemeMode themeMode = ThemeMode.system;
  
  @enumerated
  SortOrder inventorySortOrder = SortOrder.expirationDate;
}

enum ShoppingFrequency {
  weekly,      // Every X day of week
  biweekly,    // Every 2 weeks on X day
  monthly,     // Every month on X date
  payCycle,    // Specific dates (15th, 30th)
  custom       // User-selected days
}

enum SyncMode {
  localOnly,
  cloudSync,
  wifiSync,
  selfHosted
}

enum ThemeMode {
  light,
  dark,
  system
}

enum SortOrder {
  name,
  expirationDate,
  purchaseDate,
  location,
  quantity
}
```

---

## 🔌 API INTEGRATIONS

### 1. Open Food Facts API

**Purpose:** Auto-populate product info from barcodes

**Base URL:** `https://world.openfoodfacts.org/api/v2`

**Endpoint:** `GET /product/{barcode}`

**Example Request:**
```dart
final response = await http.get(
  Uri.parse('https://world.openfoodfacts.org/api/v2/product/0041220576500')
);

// Returns product data including:
// - product_name
// - brands
// - categories
// - image_url
// - ingredients
// - nutriscore
```

**Example Response:**
```json
{
  "code": "0041220576500",
  "product": {
    "product_name": "Hidden Valley Ranch Dressing",
    "brands": "Hidden Valley",
    "categories": "Dressings, Ranch dressing",
    "image_url": "https://images.openfoodfacts.org/...",
    "quantity": "16 fl oz (473 mL)"
  },
  "status": 1,
  "status_verbose": "product found"
}
```

**Service Implementation:**
```dart
class OpenFoodFactsService {
  static const baseUrl = 'https://world.openfoodfacts.org/api/v2';
  
  Future<ProductInfo?> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$barcode')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          return ProductInfo.fromJson(data['product']);
        }
      }
      return null;  // Product not found
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }
}
```

**Fallback Strategy:**
1. Try Open Food Facts
2. If not found, try UPC Database API (backup)
3. If still not found, manual entry

---

### 2. Discord Webhooks

**Purpose:** Send expiration alerts to Discord channel

**Setup:**
1. User creates webhook in Discord server settings
2. Copies webhook URL
3. Pastes in Sage settings
4. App sends JSON POST requests to webhook

**Example Webhook URL:**
```
https://discord.com/api/webhooks/123456789/abcdef...
```

**Sending a Message:**
```dart
class DiscordService {
  Future<void> sendAlert(String webhookUrl, List<FoodItem> expiringItems) async {
    final message = _buildAlertMessage(expiringItems);
    
    final response = await http.post(
      Uri.parse(webhookUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': 'Sage Kitchen Alert',
        'avatar_url': 'https://sage-app.com/icon.png',
        'embeds': [
          {
            'title': '🌿 Sage Alert 🌿',
            'description': message,
            'color': 0x4CAF50,  // Green
            'footer': {
              'text': 'Sage Kitchen Management'
            },
            'timestamp': DateTime.now().toIso8601String()
          }
        ]
      })
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to send Discord alert');
    }
  }
  
  String _buildAlertMessage(List<FoodItem> items) {
    final buffer = StringBuffer();
    buffer.writeln('@everyone Shopping day is tomorrow!\n');
    buffer.writeln('**Expiring before next week:**');
    
    for (final item in items) {
      final emoji = _getEmoji(item.daysUntilExpiration);
      buffer.writeln('$emoji ${item.name} (expires in ${item.daysUntilExpiration} days)');
    }
    
    buffer.writeln('\nDon\'t forget to restock! 🛒');
    return buffer.toString();
  }
  
  String _getEmoji(int days) {
    if (days <= 3) return '🔴';
    if (days <= 7) return '🟡';
    return '🟢';
  }
}
```

**Rate Limiting:**
- Discord allows ~5 requests per second per webhook
- Batch alerts together
- Use exponential backoff if rate limited

---

## 📱 USER FLOWS

### Flow 1: First Time Setup

```
User downloads Sage
    ↓
Welcome screen
    ↓
Choose sync mode:
  - Local only (skip to next)
  - Cloud sync (sign up/login)
  - Self-hosted (enter URL)
    ↓
Set shopping frequency:
  "How often do you shop?"
  - Weekly → Pick day
  - Bi-weekly → Pick day
  - Monthly → Pick date
  - Pay cycle → Enter dates
  - Custom → Select days
    ↓
Enable notifications:
  "Get alerts for expiring items?"
  - Yes (request permission)
  - No (can enable later)
    ↓
Optional: Discord setup
  "Send alerts to Discord?"
  - Yes → Paste webhook URL → Test
  - Skip
    ↓
Tutorial:
  "Let's add your first item!"
  - Scan barcode demo
  - OR manual entry
    ↓
Ready to use! 🎉
```

---

### Flow 2: Adding Item via Barcode

```
User taps "+ Add Item"
    ↓
Choose method:
  [📷 Scan Barcode] or [✏️ Manual Entry]
    ↓
User taps "Scan Barcode"
    ↓
Camera opens with barcode overlay
    ↓
User scans barcode
    ↓
Query Open Food Facts API
    ↓
┌─────────────────────┐
│  Product Found?     │
└────┬────────────┬───┘
     │            │
    YES          NO
     │            │
     ▼            ▼
Auto-fill:    Manual Entry:
- Name        - Type name
- Photo       - Optional photo
- Category    - Select category
     │            │
     └────┬───────┘
          ▼
User adds:
  - Quantity (1, 2, 3...)
  - Unit (bottles, lbs, etc.)
  - Expiration date (calendar picker)
  - Location (dropdown: Fridge/Freezer/Pantry)
  - Optional notes
    ↓
[Save] button
    ↓
Save to local database
    ↓
If cloud sync enabled:
  Queue for sync
    ↓
Show success message
Navigate to inventory screen
```

---

### Flow 3: Meal Planning with Recipes

```
User opens Recipes tab
    ↓
Browses recipes OR taps "What Can I Make?"
    ↓
IF "What Can I Make?":
  System matches recipes to current inventory
  Shows % of ingredients available
  "Caesar Salad: 75% (missing croutons)"
    ↓
User selects recipe
    ↓
Recipe details screen shows:
  - Photo
  - Ingredients with checkmarks:
    ✅ Romaine lettuce (in fridge)
    ✅ Ranch dressing (in pantry)
    ❌ Croutons (not in inventory)
  - Instructions
  - Prep time
    ↓
User taps "Add Missing Items to Shopping List"
    ↓
Dialog: "Add to which list?"
  - Select existing list
  - OR create new list
    ↓
Croutons added to shopping list
    ↓
User cooks meal!
    ↓
Optional: Mark ingredients as used
  (Reduces quantity in inventory)
```

---

### Flow 4: Shopping Trip

```
User opens Shopping tab
    ↓
Selects "Costco" shopping list
    ↓
List shows:
  ☐ Milk (2 gallons)
  ☐ Chicken (2 lbs)
  ☐ Croutons (1 bag)
  ☑ Eggs (already checked off yesterday)
    ↓
At store, user checks off items:
  ☑ Milk
  ☑ Chicken
  ☑ Croutons
    ↓
All items checked!
    ↓
Banner appears:
  "Shopping complete! Add items to inventory?"
  [Yes] [Not yet]
    ↓
User taps [Yes]
    ↓
Bulk add screen:
  Pre-filled with checked items
  User adds:
    - Expiration dates (smart defaults shown)
    - Locations (remembered from last time)
  Quick swipe interface
    ↓
[Save All] button
    ↓
All items added to inventory
Shopping list cleared (or moved to archive)
    ↓
Success! 🎉
```

---

### Flow 5: Responding to Expiration Alert

```
Morning notification:
  "🌿 Sage: Use soon!
   Ranch dressing expires in 3 days"
    ↓
User taps notification
    ↓
App opens to "Use It Up" screen
    ↓
Shows recipes featuring ranch:
  - Buffalo Chicken Wrap
  - Veggie Dip Platter
  - Ranch Chicken Tacos
    ↓
User selects "Buffalo Chicken Wrap"
    ↓
Checks ingredients:
  ✅ Ranch dressing (expiring!)
  ✅ Tortillas
  ✅ Lettuce
  ❌ Chicken (needs to buy)
    ↓
Adds chicken to shopping list
    ↓
Makes dinner, ranch dressing used!
    ↓
User marks ranch as "used up" in app
  OR reduces quantity to 0
    ↓
Item removed from inventory
Food waste prevented! 💪
```

---

## 🔔 NOTIFICATION SYSTEM (DETAILED)

### Background Job Architecture

**Strategy:** Scheduled daily check + immediate calculations

```dart
class ExpirationTrackerService {
  final InventoryRepository _inventory;
  final SettingsRepository _settings;
  final NotificationService _notifications;
  
  Future<void> runDailyCheck() async {
    // Run every morning at 9 AM
    final items = await _inventory.getAllItems();
    final settings = await _settings.getSettings();
    final nextShoppingDay = settings.nextShoppingDay;
    
    for (final item in items) {
      await _checkItemAndNotify(item, nextShoppingDay);
    }
  }
  
  Future<void> _checkItemAndNotify(FoodItem item, DateTime? nextShopping) async {
    final daysUntil = item.daysUntilExpiration;
    
    // 1 month notification
    if (daysUntil == 30) {
      await _notifications.schedule(
        title: '🌿 Sage: FYI',
        body: '${item.name} expires in 30 days',
        payload: 'item:${item.id}',
      );
    }
    
    // 2 weeks notification
    if (daysUntil == 14) {
      await _notifications.schedule(
        title: '🌿 Sage: Heads up!',
        body: '${item.name} expires in 2 weeks',
        payload: 'item:${item.id}',
      );
    }
    
    // 1 week notification
    if (daysUntil == 7) {
      await _notifications.schedule(
        title: '🌿 Sage: Use soon!',
        body: '${item.name} expires in 1 week - Tap for recipes',
        payload: 'useItUp:${item.id}',
      );
    }
    
    // Shopping day check
    if (nextShopping != null) {
      if (item.expirationDate.isBefore(nextShopping) && daysUntil > 0) {
        await _notifications.schedule(
          title: '🌿 Sage: Add to shopping list!',
          body: '${item.name} expires before your next shopping trip',
          payload: 'addToList:${item.id}',
        );
      }
    }
  }
}
```

### Shopping Day Calculation

```dart
class ShoppingDayCalculator {
  DateTime? calculateNextShoppingDay(UserSettings settings) {
    final now = DateTime.now();
    
    switch (settings.frequency) {
      case ShoppingFrequency.weekly:
        return _nextWeekday(now, settings.dayOfWeek!);
        
      case ShoppingFrequency.biweekly:
        return _nextBiweekly(now, settings.dayOfWeek!);
        
      case ShoppingFrequency.monthly:
        return _nextMonthlyDate(now, settings.dayOfMonth!);
        
      case ShoppingFrequency.payCycle:
        return _nextPayCycleDate(now, settings.payCycleDays!);
        
      case ShoppingFrequency.custom:
        return _nextCustomDay(now, settings.customDays!);
    }
  }
  
  DateTime _nextWeekday(DateTime from, int targetDay) {
    // targetDay: 1 = Monday, 7 = Sunday
    final currentDay = from.weekday;
    int daysToAdd = (targetDay - currentDay) % 7;
    if (daysToAdd == 0) daysToAdd = 7;  // Next week
    return from.add(Duration(days: daysToAdd));
  }
  
  DateTime _nextBiweekly(DateTime from, int targetDay) {
    final nextWeek = _nextWeekday(from, targetDay);
    // Check if last shopping was less than a week ago
    // If yes, return 2 weeks from last shopping
    // If no, return next week
    // (Would need to store last shopping date)
    return nextWeek.add(Duration(days: 7));  // Simplified
  }
  
  DateTime _nextMonthlyDate(DateTime from, int targetDate) {
    var next = DateTime(from.year, from.month, targetDate);
    if (next.isBefore(from) || next.isAtSameMomentAs(from)) {
      // Next month
      next = DateTime(from.year, from.month + 1, targetDate);
    }
    return next;
  }
  
  DateTime _nextPayCycleDate(DateTime from, List<int> dates) {
    // dates like [15, 30]
    final upcoming = dates
        .map((d) => DateTime(from.year, from.month, d))
        .where((date) => date.isAfter(from))
        .toList()
      ..sort();
    
    if (upcoming.isEmpty) {
      // Next month
      final firstDate = dates.first;
      return DateTime(from.year, from.month + 1, firstDate);
    }
    
    return upcoming.first;
  }
  
  DateTime _nextCustomDay(DateTime from, List<int> days) {
    // days like [1, 4, 6] = Monday, Thursday, Saturday
    final upcoming = days
        .map((d) => _nextWeekday(from, d))
        .toList()
      ..sort();
    
    return upcoming.first;
  }
}
```

---

## 🔐 SECURITY & PRIVACY

### Data Privacy Principles

1. **Local-First:** All data stored locally first, cloud is optional
2. **User Control:** Users choose sync mode and what to share
3. **No Tracking:** Zero analytics, no user tracking
4. **Open Source:** Code is public, verifiable
5. **Self-Hostable:** Users can run own backend

### Cloud Security (Supabase)

**Row-Level Security (RLS) Policies:**

```sql
-- Users can only see their own items
CREATE POLICY "Users see own items"
  ON food_items
  FOR SELECT
  USING (auth.uid() = user_id);

-- Household members see shared items
CREATE POLICY "Household access"
  ON food_items
  FOR SELECT
  USING (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid()
    )
  );

-- Users can only modify their own items
CREATE POLICY "Users modify own items"
  ON food_items
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Similar policies for recipes, shopping lists, etc.
```

**Authentication:**
- Email/password (Supabase Auth)
- Optional: OAuth (Google, Apple) in future
- JWT tokens for API requests
- Refresh tokens for sessions

### Local Security

**Database Encryption:**
```dart
// Isar supports encryption
final isar = await Isar.open(
  [FoodItemSchema, RecipeSchema, ...],
  directory: dir.path,
  inspector: false,
  encryptionKey: _getOrCreateEncryptionKey(),
);
```

**Secure Storage:**
- User settings encrypted
- Discord webhook URL secured
- Auth tokens in secure storage (flutter_secure_storage)

---

## 🧪 TESTING STRATEGY

### Unit Tests
Test individual functions and business logic

```dart
// Example: Test expiration calculation
test('daysUntilExpiration calculates correctly', () {
  final item = FoodItem()
    ..name = 'Milk'
    ..expirationDate = DateTime.now().add(Duration(days: 5));
  
  expect(item.daysUntilExpiration, equals(5));
});

test('expirationStatus returns correct status', () {
  final item = FoodItem()
    ..name = 'Milk'
    ..expirationDate = DateTime.now().add(Duration(days: 2));
  
  expect(item.expirationStatus, equals(ExpirationStatus.critical));
});
```

### Widget Tests
Test UI components

```dart
testWidgets('ExpirationBadge shows correct color', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ExpirationBadge(daysUntil: 2),
    ),
  );
  
  expect(find.text('2 days'), findsOneWidget);
  
  final badge = tester.widget<Container>(find.byType(Container));
  expect(badge.color, equals(Colors.red));  // Critical = red
});
```

### Integration Tests
Test complete user flows

```dart
testWidgets('Add item flow works end-to-end', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Tap add button
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  // Choose manual entry
  await tester.tap(find.text('Manual Entry'));
  await tester.pumpAndSettle();
  
  // Fill form
  await tester.enterText(find.byKey(Key('name_field')), 'Milk');
  await tester.enterText(find.byKey(Key('quantity_field')), '1');
  
  // Select expiration date
  await tester.tap(find.byKey(Key('expiration_picker')));
  // ... date picker interaction
  
  // Save
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  
  // Verify item appears in inventory
  expect(find.text('Milk'), findsOneWidget);
});
```

---

## 🚀 DEPLOYMENT

### Android Release Process

1. **Build Release APK:**
```bash
flutter build apk --release
```

2. **Build App Bundle (for Play Store):**
```bash
flutter build appbundle --release
```

3. **Sign the Build:**
   - Configure signing in `android/app/build.gradle`
   - Store keystore securely
   - Add to `.gitignore`

4. **Upload to Play Store:**
   - Internal testing → Alpha → Beta → Production
   - Gradual rollout recommended

### iOS Release Process

1. **Prerequisites:**
   - Apple Developer account ($99/year)
   - Xcode installed
   - Provisioning profiles configured

2. **Build:**
```bash
flutter build ios --release
```

3. **Archive in Xcode:**
   - Open `ios/Runner.xcworkspace`
   - Product → Archive
   - Upload to App Store Connect

4. **TestFlight:**
   - Internal testing
   - External beta testing
   - Submit for review

### Self-Hosted Backend Deployment

**Docker Compose Setup:**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: sage
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  api:
    image: sage-backend:latest
    depends_on:
      - postgres
    environment:
      DATABASE_URL: postgresql://postgres:${DB_PASSWORD}@postgres:5432/sage
      JWT_SECRET: ${JWT_SECRET}
    ports:
      - "3000:3000"

volumes:
  postgres_data:
```

**Deploy on Raspberry Pi:**
```bash
# On Raspberry Pi
git clone https://github.com/sage-app/backend
cd backend
cp .env.example .env
# Edit .env with your settings
docker-compose up -d
```

---

## 📊 METRICS & ANALYTICS

### Privacy-Respecting Metrics

**What we DON'T track:**
- Personal data
- Specific food items
- User behavior
- Location data

**What we CAN track (locally, opt-in):**
- Items saved (count only, for user's stats)
- Food waste prevented (estimated)
- Money saved (estimated from item costs)
- App usage (locally, for user dashboard)

**User Dashboard:**
```
Your Stats (This Month):
- 🛒 24 items tracked
- 💰 Estimated savings: $47
- 🌱 Food waste prevented: 3 lbs
- 📖 Recipes tried: 5
- ⭐ Most used recipe: Caesar Salad
```

---

## 🎨 DESIGN SYSTEM

### Color Palette

```dart
class AppColors {
  // Primary - Sage Green theme
  static const primary = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF388E3C);
  static const primaryLight = Color(0xFF81C784);
  
  // Expiration Status Colors
  static const fresh = Color(0xFF4CAF50);      // Green
  static const caution = Color(0xFFFFEB3B);    // Yellow
  static const warning = Color(0xFFFF9800);    // Orange
  static const critical = Color(0xFFF44336);   // Red
  static const expired = Color(0xFF9E9E9E);    // Gray
  
  // UI
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}
```

### Typography

```dart
class AppTextStyles {
  static const headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );
  
  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}
```

---

## 🔮 FUTURE FEATURES

### Phase 8+ (Post-MVP)

1. **Meal Planning Calendar**
   - Plan meals for the week
   - Auto-generate shopping list
   - Track what you ate

2. **Nutrition Tracking**
   - From Open Food Facts nutrition data
   - Track calories, macros (optional)
   - Health insights

3. **Price Tracking**
   - Log item costs
   - Track spending over time
   - Price comparison between stores

4. **Voice Input**
   - "Hey Sage, add milk to my shopping list"
   - Voice-activated barcode scanning

5. **AI Recipe Suggestions**
   - "What can I make with chicken and rice?"
   - Generate recipes from ingredients
   - Dietary restrictions

6. **Household Gamification**
   - Compete to waste less food
   - Achievements & badges
   - Family leaderboard

7. **Integration with Smart Appliances**
   - Samsung Family Hub fridge
   - Smart scales for quantity tracking

---

**Built with 💚 by enthusiastic developers who hate wasting food!**

**Let's make kitchens smarter, one scan at a time! 🌿**
