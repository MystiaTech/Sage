# SAGE - KITCHEN MANAGEMENT APP
## 🎯 Project Plan & Current Status

**Last Updated:** October 3, 2025
**Status:** Planning Phase - Ready to Start Development! 🔥

---

## 📱 WHAT IS SAGE?

Sage is a smart kitchen management app that helps you:
- Track food inventory and expiration dates
- Never waste food or money again
- Manage recipes and generate shopping lists
- Share with family/household members
- Get Discord notifications for expiring items

**Why "Sage"?** 
- The herb (kitchen theme!)
- Wisdom and smart decisions
- Simple, memorable, perfect! 💚

---

## ✅ COMPLETED

### Planning & Design
- [x] Core feature set defined
- [x] Technical stack selected
- [x] Database choices made
- [x] UI/UX flow planned
- [x] Project documentation created

---

## 🎯 CURRENT PHASE: PHASE 1 - FOUNDATION

### What We're Building Now
Setting up the Flutter project and building the core inventory tracker with local database.

### Phase 1 Checklist
- [ ] Install Flutter & Android Studio
- [ ] Create new Flutter project "sage"
- [ ] Set up project structure
- [ ] Install initial dependencies (sqflite/isar, riverpod)
- [ ] Create database schema
- [ ] Build basic UI framework (bottom navigation)
- [ ] Create home screen
- [ ] Build "Add Item" screen (manual entry)
- [ ] Implement local database (CRUD operations)
- [ ] Display inventory list
- [ ] Edit/delete items functionality
- [ ] Test everything works offline

**Estimated Time:** Week 1-2

---

## 🚀 UPCOMING PHASES

### PHASE 2: BARCODE MAGIC (Week 2-3)
**Goal:** Scan barcodes and auto-populate items from Open Food Facts

**Tasks:**
- [ ] Install mobile_scanner package
- [ ] Implement barcode scanner UI
- [ ] Connect to Open Food Facts API
- [ ] Parse API response and auto-fill item details
- [ ] Cache product photos locally
- [ ] Handle "product not found" gracefully (fallback to manual)
- [ ] Test with various products

**Key Decisions:**
- Use Open Food Facts (free, 2M+ products!)
- Cache images using cached_network_image
- Manual entry always available as backup

---

### PHASE 3: ALERTS & NOTIFICATIONS (Week 3-4)
**Goal:** Never let food expire without warning!

**Tasks:**
- [ ] Implement expiration tracking logic
- [ ] Set up flutter_local_notifications
- [ ] Create notification scheduler
- [ ] Build alert timeline:
  - [ ] 1 month before expiration
  - [ ] 2 weeks before expiration
  - [ ] 1 week before expiration
  - [ ] Shopping day alert (customizable)
- [ ] Add "Shopping Frequency" setting (weekly, bi-weekly, monthly, pay cycle)
- [ ] Calculate shopping day alerts based on frequency
- [ ] Discord webhook integration
- [ ] Settings screen for Discord webhook URL
- [ ] Test notification button
- [ ] Handle notification permissions

**Alert Logic:**
```
If item expires before next shopping day:
  → Send "Add to shopping list" alert
  → Send to Discord channel
  
If item expires within 1 week:
  → Send "Use soon!" alert
  → Suggest recipes using this item
```

---

### PHASE 4: RECIPES (Week 4-5)
**Goal:** Store recipes and connect them to inventory

**Tasks:**
- [ ] Design recipe data model
- [ ] Create recipe database table
- [ ] Build "Add Recipe" screen
- [ ] Copy/paste from websites parser
- [ ] Manual recipe entry
- [ ] Ingredient list with quantities
- [ ] Instructions/notes field
- [ ] Optional photo upload
- [ ] Recipe categories/tags
- [ ] View recipe details
- [ ] Edit/delete recipes
- [ ] "What Can I Make?" logic (match recipes to inventory)
- [ ] Recipe sharing functionality

**Data Structure:**
```
Recipe:
  - id
  - name
  - ingredients[] (name, quantity, unit)
  - instructions
  - photo (optional)
  - tags[]
  - created_by (user_id for sharing)
  - is_public (shareable or private)
```

---

### PHASE 5: SHOPPING LISTS (Week 5-6)
**Goal:** Never forget ingredients again!

**Tasks:**
- [ ] Shopping list data model
- [ ] Multiple lists support (Costco, Trader Joe's, etc.)
- [ ] Create/rename/delete lists
- [ ] Add items manually
- [ ] Add items from recipes (one-click)
- [ ] Check off items while shopping
- [ ] Quick-add to inventory after shopping
- [ ] List sharing with others
- [ ] Sort by store section (optional feature)
- [ ] Shopping history (what you usually buy)

**User Flow:**
```
1. Pick recipe → See missing ingredients → Add to shopping list
2. At store → Check off items as you shop
3. Home from store → Quick-add checked items to inventory
4. BOOM → Everything tracked!
```

---

### PHASE 6: MULTI-USER & CLOUD SYNC (Week 6-7)
**Goal:** Share with household, sync across devices

**Sync Options (User Choice):**

**Option 1: Cloud Sync (Supabase)**
- Free tier: 500MB database, 2GB bandwidth
- Real-time sync
- User authentication
- Shared households

**Option 2: Completely Free (Self-Hosted)**
- Export/Import JSON files
- Local WiFi sync (peer-to-peer)
- Optional: Self-host simple backend (we provide Docker setup)
- No external dependencies!

**Option 3: Local Only**
- Everything on device
- Export for backup
- Import to share with others
- Zero cloud dependency

**Tasks:**
- [ ] Set up Supabase project
- [ ] User authentication (email/password)
- [ ] Cloud database schema
- [ ] Sync logic (offline-first!)
- [ ] Conflict resolution (last-write-wins)
- [ ] Household/family groups
- [ ] Invite system (QR code or link)
- [ ] Share permissions (view/edit)
- [ ] Export to JSON feature
- [ ] Import from JSON feature
- [ ] Local WiFi sync option
- [ ] Self-hosted backend docs (Docker Compose)

**Offline-First Strategy:**
```
1. All changes save locally FIRST
2. Queue changes for sync
3. Sync when online
4. Handle conflicts gracefully
5. App works PERFECTLY offline
```

---

### PHASE 7: SMART FEATURES (Week 7-8)
**Goal:** Make Sage actually INTELLIGENT

**Tasks:**
- [ ] "What Can I Make?" recipe matcher
  - Match recipes to current inventory
  - Show % of ingredients you have
  - Sort by "most complete" recipes
- [ ] "Use It Up" suggestions
  - Find recipes using expiring items
  - Prioritize items expiring soonest
- [ ] Search functionality (inventory, recipes, shopping lists)
- [ ] Advanced filters (location, category, expiration date)
- [ ] Categories & organization
  - Auto-categorize from barcode
  - Manual category assignment
  - Custom categories
- [ ] Statistics dashboard
  - Money saved (estimated)
  - Food waste prevented
  - Most used recipes
- [ ] UI/UX polish
  - Smooth animations
  - Beautiful color scheme
  - Intuitive navigation
  - Accessibility features

---

## 💾 TECH STACK

### Core Framework
- **Flutter** (Dart language)
- Cross-platform (Android & iOS from one codebase!)

### Database
- **Isar** - Local database (super fast, Flutter-optimized)
- **Supabase** - Cloud sync (optional)
- **SQLite fallback** - If Isar has issues

### State Management
- **Riverpod** - Modern, clean, powerful

### Key Packages
```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.4.0
  
  # Database
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  
  # Barcode Scanning
  mobile_scanner: ^3.5.0
  
  # API Calls
  http: ^1.1.0
  
  # Notifications
  flutter_local_notifications: ^16.0.0
  timezone: ^0.9.2
  
  # Images
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0
  
  # Cloud (Optional)
  supabase_flutter: ^2.0.0
  
  # Utilities
  intl: ^0.18.0  # Date formatting
  path_provider: ^2.1.0  # File paths
  share_plus: ^7.2.0  # Sharing
  qr_flutter: ^4.1.0  # QR codes for sharing
  
dev_dependencies:
  # Code Generation
  isar_generator: ^3.1.0
  build_runner: ^2.4.0
```

---

## 📊 DATA MODELS

### Food Item
```dart
@collection
class FoodItem {
  Id id = Isar.autoIncrement;
  
  late String name;
  String? barcode;
  late int quantity;
  String? unit;  // "bottles", "lbs", "oz", etc.
  
  late DateTime purchaseDate;
  late DateTime expirationDate;
  
  @enumerated
  late Location location;  // fridge, freezer, pantry, etc.
  
  String? category;  // dairy, produce, condiments, etc.
  String? photoUrl;
  String? notes;
  
  // For multi-user
  String? userId;
  String? householdId;
  
  // Sync tracking
  DateTime? lastModified;
  bool syncedToCloud = false;
}

enum Location {
  fridge,
  freezer,
  pantry,
  spiceRack,
  other
}
```

### Recipe
```dart
@collection
class Recipe {
  Id id = Isar.autoIncrement;
  
  late String name;
  late List<Ingredient> ingredients;
  late String instructions;
  
  String? photoUrl;
  List<String> tags = [];
  
  int? prepTime;  // minutes
  int? servings;
  
  // Sharing
  String? createdBy;  // user_id
  bool isPublic = false;
  
  DateTime? created;
  DateTime? lastModified;
  bool syncedToCloud = false;
}

@embedded
class Ingredient {
  late String name;
  double? quantity;
  String? unit;
  bool? optional;
}
```

### Shopping List
```dart
@collection
class ShoppingList {
  Id id = Isar.autoIncrement;
  
  late String name;  // "Costco", "Trader Joe's", etc.
  List<ShoppingItem> items = [];
  
  // Sharing
  String? householdId;
  List<String> sharedWith = [];
  
  DateTime? created;
  DateTime? lastModified;
  bool syncedToCloud = false;
}

@embedded
class ShoppingItem {
  late String name;
  double? quantity;
  String? unit;
  bool checked = false;
  int? priority;  // 1-5
  String? addedFrom;  // "recipe_id" or "manual"
}
```

### User Settings
```dart
@collection
class UserSettings {
  Id id = Isar.autoIncrement;
  
  // Shopping frequency
  @enumerated
  ShoppingFrequency frequency = ShoppingFrequency.weekly;
  
  // If custom schedule
  List<int>? customDays;  // [1, 4] = Monday & Thursday
  
  // Next shopping day (calculated)
  DateTime? nextShoppingDay;
  
  // Notifications
  bool enableNotifications = true;
  bool enableDiscord = false;
  String? discordWebhookUrl;
  
  // Sync preferences
  @enumerated
  SyncMode syncMode = SyncMode.localOnly;
  
  // Display preferences
  bool showPhotos = true;
  @enumerated
  ThemeMode themeMode = ThemeMode.system;
}

enum ShoppingFrequency {
  weekly,
  biweekly,
  monthly,
  payCycle,  // Every 2 weeks on specific days
  custom
}

enum SyncMode {
  localOnly,
  cloudSync,
  wifiSync,
  selfHosted
}
```

---

## 🎨 UI/UX FLOW

### Bottom Navigation
1. **Home** (🏠) - Dashboard with expiring items
2. **Inventory** (📦) - All food items
3. **Recipes** (📖) - Recipe book
4. **Shopping** (🛒) - Shopping lists
5. **Settings** (⚙️) - Preferences & sync

### Home Screen Layout
```
┌─────────────────────────────┐
│  SAGE 🌿                    │
├─────────────────────────────┤
│  Expiring Soon              │
│  ┌───────┐ ┌───────┐       │
│  │ Ranch │ │ Milk  │  →→   │
│  │ 3 days│ │ 5 days│       │
│  └───────┘ └───────┘       │
├─────────────────────────────┤
│  Quick Stats                │
│  📦 24 items in inventory   │
│  🛒 7 items on shopping list│
│  📖 12 saved recipes        │
├─────────────────────────────┤
│        [+] Add Item         │
│     [📷] Scan Barcode       │
└─────────────────────────────┘
```

### Add Item Flow
```
Scan Barcode
    ↓
Found in database?
    ├─ YES → Auto-fill name, photo, category
    │         User adds: quantity, expiration, location
    │         → Save to inventory
    │
    └─ NO → Manual entry form
             User adds: name, quantity, expiration, location
             → Save to inventory
```

### Notification Flow
```
Background job runs daily:
  1. Check all items' expiration dates
  2. Calculate time until expiration
  3. Check user's next shopping day
  
  For each item:
    - 1 month away? → Send "FYI" notification
    - 2 weeks away? → Send "Getting close" notification
    - 1 week away? → Send "Use soon!" notification
    - Expires before next shopping day? → Send "Add to list!" + Discord alert
```

---

## 🔔 NOTIFICATION EXAMPLES

**1 Month Alert:**
```
🌿 Sage: FYI
Ranch dressing expires in 30 days
```

**2 Week Alert:**
```
🌿 Sage: Heads up!
Sour cream expires in 14 days
```

**1 Week Alert:**
```
🌿 Sage: Use soon!
Milk expires in 7 days
Tap to see recipes →
```

**Shopping Day Alert:**
```
🌿 Sage: Shopping tomorrow!
3 items expire before next week:
• Ranch dressing
• Croutons  
• Caesar salad kit

Add to shopping list?
```

**Discord Alert Example:**
```
🌿 **Sage Alert** 🌿
@everyone Shopping day is tomorrow!

**Expiring before next week:**
🔴 Ranch dressing (expires Oct 10)
🔴 Croutons (expires Oct 12)
🟡 Milk (expires Oct 15)

Don't forget to restock! 🛒
```

---

## 🎯 SUCCESS METRICS

**How do we know Sage is WORKING?**

1. **User saves money**
   - Less food waste
   - Fewer emergency takeout orders
   - Better grocery planning

2. **User saves time**
   - No more "what can I make?" confusion
   - Quick shopping trips (have a list!)
   - Organized kitchen

3. **App is reliable**
   - Works offline
   - Fast and responsive
   - Accurate notifications

4. **Users love it**
   - Easy to use
   - Beautiful design
   - Actually helps daily life

---

## 🚨 POTENTIAL CHALLENGES

### Challenge 1: Barcode Database Coverage
**Problem:** Not all products in Open Food Facts  
**Solution:** 
- Manual entry always available
- Allow users to contribute photos/info
- Multiple API fallbacks (UPC Database, etc.)

### Challenge 2: Expiration Date Entry
**Problem:** Users might not enter accurate dates  
**Solution:**
- Default suggestions based on product type
- "Best by" vs "use by" education
- Calendar picker with smart defaults

### Challenge 3: Notification Overload
**Problem:** Too many alerts = users ignore them  
**Solution:**
- Smart batching (daily digest option)
- Priority levels
- Customizable alert preferences
- Only critical alerts to Discord

### Challenge 4: Multi-User Sync Conflicts
**Problem:** Two people edit same item simultaneously  
**Solution:**
- Last-write-wins with timestamp
- Conflict notification (rare)
- Clear "last updated by" info

### Challenge 5: Free Hosting for Self-Hosted Option
**Problem:** Users need to host backend  
**Solution:**
- Super simple Docker Compose setup
- Can run on Raspberry Pi at home!
- Full documentation
- Optional: Fly.io free tier

---

## 📱 PLATFORM SUPPORT

**Phase 1-7:** Android only (easier testing)  
**Phase 8:** iOS support (Flutter makes this easy!)  
**Future:** Web app? Desktop app?

---

## 🎉 VISION

Imagine this:
- You never waste food again
- Your grocery trips are EFFICIENT
- You always know what to make for dinner
- Your household is coordinated
- You save hundreds of dollars a year

That's what Sage makes possible! 💚

---

## 📝 NEXT STEPS (RIGHT NOW!)

1. [ ] Install Flutter & Android Studio
2. [ ] Create SAGE_PROJECT.md (full documentation)
3. [ ] Create PROJECT_STRUCTURE.md (file organization)
4. [ ] Initialize Flutter project
5. [ ] Set up Git repository
6. [ ] Start Phase 1! 🔥

---

**LET'S BUILD SAGE! 💪✨**

---

## 📚 RESOURCES

### Learning Flutter (for beginners!)
- Flutter Docs: https://docs.flutter.dev/
- Flutter Codelabs: https://docs.flutter.dev/codelabs
- Riverpod Docs: https://riverpod.dev/
- Isar Docs: https://isar.dev/

### APIs We're Using
- Open Food Facts: https://world.openfoodfacts.org/
- Discord Webhooks: https://discord.com/developers/docs/resources/webhook

### Design Inspiration
- Material Design 3: https://m3.material.io/
- Flutter Gallery: https://gallery.flutter.dev/

---

**Created with ✨ by CC and girlfriend!**
**Last updated: October 3, 2025**
