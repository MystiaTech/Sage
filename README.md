# 🌿 Sage - Smart Kitchen Management

A beautiful Flutter app for tracking your kitchen inventory and reducing food waste.

## Features

✅ **Smart Inventory Management**
- Barcode scanning for quick item entry
- Auto-populated product information from multiple databases
- Smart expiration date predictions based on food category
- Visual expiration status indicators

✅ **Modern UI**
- Clean, intuitive Material Design 3 interface
- Sage green theme
- Custom sage leaf vector icon
- Smooth animations and transitions

✅ **Notifications**
- Local expiration alerts
- Discord webhook integration for remote notifications
- Customizable alert settings (persisted!)

✅ **Local-First Data**
- All data stored locally using Hive
- No cloud dependencies
- Privacy-focused design
- Fast and offline-capable

## Tech Stack

- **Framework**: Flutter 3.35.5
- **State Management**: Riverpod 2.6.1
- **Database**: Hive 2.2.3 (local)
- **Barcode Scanning**: mobile_scanner 5.2.3
- **API Integration**: Open Food Facts, UPCItemDB
- **Platform**: Android (iOS coming soon)

## Getting Started

### Prerequisites
- Flutter 3.x installed
- Android Studio or VS Code
- Android SDK (for mobile) or Visual Studio (for Windows desktop)

### Setup

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# On Android device/emulator
flutter run

# On Windows (for development)
flutter run -d windows
```

## Project Structure

```
sage/
├── lib/
│   ├── core/              # Core utilities, constants, extensions
│   ├── features/          # Feature modules (inventory, recipes, etc.)
│   ├── services/          # Business logic services
│   ├── data/              # Data layer (local + remote)
│   └── shared/            # Shared widgets and providers
├── assets/                # Images, icons, fonts
└── test/                  # Tests
```

## Documentation

- [PLAN.md](PLAN.md) - Development roadmap and current status
- [SAGE_PROJECT.md](SAGE_PROJECT.md) - Complete project documentation
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Detailed architecture guide
- [CLAUDE.md](CLAUDE.md) - AI assistant personality template

## Roadmap

- **Phase 1:** Foundation - Basic inventory tracker ⏳ IN PROGRESS
- **Phase 2:** Barcode scanning with Open Food Facts
- **Phase 3:** Smart alerts & notifications
- **Phase 4:** Recipe management
- **Phase 5:** Shopping lists
- **Phase 6:** Multi-user & cloud sync
- **Phase 7:** Advanced features & polish

## Contributing

This is currently a personal project, but ideas and suggestions are welcome!

## License

TBD

---

**Built with 💚 by developers who hate wasting food!**

Let's make kitchens smarter, one scan at a time! 🌿
