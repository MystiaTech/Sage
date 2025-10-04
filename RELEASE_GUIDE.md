# Release Guide for Sage - Google Play & F-Droid

## 🔐 Step 1: Create Signing Key (Required for Google Play)

### Generate Keystore:
```bash
# Run this in your terminal (uses Java keytool)
cd android/app
keytool -genkey -v -keystore sage-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sage-key
```

**When prompted, enter:**
- Password: (choose a strong password - SAVE THIS!)
- First and last name: Danielle Sapelli
- Organizational unit: (press Enter to skip)
- Organization: (press Enter to skip)
- City: (your city)
- State: (your state)
- Country code: US (or your country)

**⚠️ CRITICAL:** Save these securely:
- Keystore password
- Key alias: `sage-key`
- Keystore file: `sage-release-key.jks`

### Configure Signing:

Create `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=sage-key
storeFile=sage-release-key.jks
```

**⚠️ Add to .gitignore:**
```
android/key.properties
android/app/sage-release-key.jks
```

### Update build.gradle.kts:

Add this to `android/app/build.gradle.kts` before `android {`:

```kotlin
// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Then update `signingConfigs` inside `android {`:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
```

And update `buildTypes`:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

## 📦 Step 2: Build Signed Release APK

```bash
flutter build apk --release
# or for app bundle (preferred for Play Store)
flutter build appbundle --release
```

Output:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## 🎨 Step 3: Create Store Assets

### App Icon (Already Done!)
✅ Custom sage leaf icon in place

### Screenshots Needed:
- **Phone:** 2-8 screenshots (1080x1920 or higher)
- **7-inch tablet:** 1-8 screenshots (1200x1920)
- **10-inch tablet:** 1-8 screenshots (1920x1200)

**Recommended screenshots:**
1. Home screen with inventory stats
2. Add item screen with barcode scanner
3. Inventory list view
4. Item expiration warnings
5. Settings with household sharing
6. Household screen showing code

### Feature Graphic (Required):
- Size: 1024w x 500h pixels
- Format: PNG or JPG
- Content: Sage logo + app name + tagline

### App Icon (512x512):
- Already have sage leaf icon
- Export at 512x512 for store listing

## 📝 Step 4: Store Listing Content

### App Title:
```
Sage - Kitchen Inventory Manager
```

### Short Description (80 chars max):
```
Smart kitchen inventory tracking. Reduce food waste, share with household.
```

### Full Description:
```
🌿 Sage - Your Smart Kitchen Management System

Sage helps you track your kitchen inventory, reduce food waste, and save money by keeping tabs on what you have and when it expires.

✨ KEY FEATURES:

📦 Smart Inventory Tracking
• Scan barcodes to add items instantly
• Automatic product information lookup
• Track expiration dates and quantities
• Organize by location (fridge, freezer, pantry)

⏰ Expiration Alerts
• See items expiring soon at a glance
• Get notifications before food goes bad
• Smart expiration date predictions by category

👨‍👩‍👧‍👦 Household Sharing
• Share inventory with family or roommates
• Real-time sync across all devices
• Everyone stays updated on what's in stock

🔍 Barcode Scanner
• Instant product lookup from multiple databases
• Auto-populate item details
• Quick and easy item entry

📊 Visual Organization
• Color-coded expiration status
• Sage leaf custom icon
• Clean Material Design 3 interface

🔒 Privacy Focused
• Local-first storage with Hive
• Optional cloud sync for households
• Your data stays on your device

💰 Completely Free
• No ads
• No subscriptions
• Open source
• No account required

🌱 Why Sage?
Named after the wise herb, Sage brings wisdom to your kitchen. Stop guessing what you have, stop throwing away expired food, and start making the most of your groceries.

Perfect for:
• Families managing shared kitchens
• Roommates coordinating grocery shopping
• Anyone wanting to reduce food waste
• People with multiple fridges/freezers
• Busy households needing organization

Made with ❤️ by Danielle Sapelli
```

### Category:
```
Food & Drink
```

### Content Rating:
```
Everyone
```

### Privacy Policy URL:
We need to host the privacy policy. Options:
1. Create a GitHub Pages site
2. Use your own website
3. Use free hosting (Netlify, Vercel)

### Contact Email:
```
(your email address)
```

## 🔧 Step 5: Google Play Console Setup

1. Go to [Google Play Console](https://play.google.com/console)
2. Create Developer Account ($25 one-time fee)
3. Create new app
4. Fill in store listing details
5. Upload screenshots
6. Upload AAB file
7. Complete content rating questionnaire
8. Submit for review

**First release timeline:** Usually 1-3 days for review

## 🤖 Step 6: F-Droid Release

F-Droid has stricter requirements:

### Requirements Checklist:

✅ **Open Source:**
- Code is open source ✓
- Need to publish to GitHub public repo

✅ **No Proprietary Dependencies:**
- ❌ **ISSUE:** Firebase is proprietary
- ❌ Google Services (google-services.json)

### F-Droid Options:

**Option 1: Remove Firebase for F-Droid build** (Recommended)
- Create build flavor without Firebase
- F-Droid users get local-only mode
- No household cloud sync, but everything else works

**Option 2: Fork for F-Droid**
- Maintain separate F-Droid version
- Strip out Firebase completely
- Local-only storage

**Option 3: Skip F-Droid**
- Focus on Google Play Store only
- Provide APK downloads from GitHub releases

### To Prepare for F-Droid:

1. **Publish code to GitHub:**
   ```bash
   # Create repo at github.com/mystiatech/sage
   git remote add origin git@github.com:mystiatech/sage.git
   git push -u origin master
   ```

2. **Add LICENSE file:**
   - Choose license (MIT, GPL-3.0, Apache-2.0)
   - Add LICENSE file to root

3. **Submit to F-Droid:**
   - Open issue at [fdroiddata](https://gitlab.com/fdroid/fdroiddata/-/issues)
   - Provide GitHub repo URL
   - They'll review and add to F-Droid

4. **Or:** Self-host F-Droid repo
   - Simpler than official F-Droid
   - Users add your repo to F-Droid app

## 📋 Final Checklist

### Google Play Store:
- [ ] Create signing key
- [ ] Configure signing in build.gradle.kts
- [ ] Build signed AAB
- [ ] Create screenshots (2-8 images)
- [ ] Create feature graphic (1024x500)
- [ ] Write store description
- [ ] Set up privacy policy hosting
- [ ] Create developer account ($25)
- [ ] Upload and submit for review

### F-Droid:
- [ ] Remove Firebase or create separate build flavor
- [ ] Publish code to GitHub
- [ ] Add LICENSE file
- [ ] Submit to F-Droid (or self-host repo)
- [ ] Wait for F-Droid review (can take weeks)

### Both:
- [ ] Test signed release build thoroughly
- [ ] Verify Firebase works with signed build
- [ ] Test on multiple devices
- [ ] Update version number for each release

## 🚀 Quick Start Commands

```bash
# Build for Google Play (signed AAB)
flutter build appbundle --release

# Build for testing (signed APK)
flutter build apk --release

# Check what's in the AAB
cd build/app/outputs/bundle/release
unzip -l app-release.aab
```

## 📱 Version Management

Current version: `1.1.0+2`

For each release:
1. Update version in `pubspec.yaml`
2. Format: `MAJOR.MINOR.PATCH+BUILD_NUMBER`
3. Example: `1.2.0+3` (version 1.2.0, build 3)

## ⚠️ Important Notes

1. **Never lose your signing key!** You can't update the app without it.
2. **Keep key.properties secure** - don't commit to git
3. **Test signed builds** before uploading to store
4. **Firebase requires google-services.json** - make sure it's the real one
5. **First release takes longer** - usually 1-3 days review
6. **Updates are faster** - usually hours after first approval

## 🆘 Common Issues

**Build fails with signing error:**
- Check key.properties exists
- Verify passwords are correct
- Make sure storeFile path is relative to android/app/

**Firebase doesn't work in release:**
- Verify google-services.json is the real one (not placeholder)
- Check package name matches exactly
- Enable Firestore in Firebase Console

**Play Store rejects:**
- Update target SDK to latest (currently 34)
- Add privacy policy URL
- Complete content rating

**F-Droid rejects:**
- Remove all proprietary dependencies
- Use only FOSS libraries
- Provide full source code
