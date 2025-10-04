# Firebase Setup Guide for Sage

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `sage-kitchen-management`
4. Disable Google Analytics (optional for this app)
5. Click "Create project"

## Step 2: Add Android App

1. In Firebase Console, click the Android icon to add an Android app
2. Enter package name: `com.github.mystiatech.sage` (must match exactly!)
3. App nickname: `Sage` (optional)
4. Debug signing certificate SHA-1: (optional, skip for now)
5. Click "Register app"

## Step 3: Download Configuration File

1. Download the `google-services.json` file
2. Place it in: `android/app/google-services.json`

## Step 4: Set up Firestore Database

1. In Firebase Console, go to "Build" → "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a Firestore location (e.g., `us-central`)
5. Click "Enable"

### Security Rules (update after testing)

For development/testing, use test mode rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 31);
    }
  }
}
```

For production, update to:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow anyone to read household data by code
    match /households/{householdId} {
      allow read: if true;
      allow create: if true;
      allow update: if true;
      allow delete: if request.auth != null;

      // Allow household members to manage items
      match /items/{itemId} {
        allow read: if true;
        allow write: if true;
      }
    }
  }
}
```

## Step 5: Update Android Build Files (Already Done)

The following files need to be updated (will be done automatically):

1. `android/build.gradle` - Add Google Services plugin
2. `android/app/build.gradle` - Apply Google Services plugin

## Step 6: Initialize Firebase in App

The app will automatically initialize Firebase on startup.

## Firestore Data Structure

```
households (collection)
  └── {householdCode} (document)
      ├── id: string
      ├── name: string
      ├── ownerName: string
      ├── createdAt: string (ISO 8601)
      └── members: array<string>
      └── items (subcollection)
          └── {itemKey} (document)
              ├── name: string
              ├── barcode: string?
              ├── quantity: number
              ├── unit: string?
              ├── purchaseDate: string (ISO 8601)
              ├── expirationDate: string (ISO 8601)
              ├── locationIndex: number
              ├── category: string?
              ├── photoUrl: string?
              ├── notes: string?
              ├── userId: string?
              ├── householdId: string
              ├── lastModified: string (ISO 8601)
              └── syncedToCloud: boolean
```

## Testing

1. Create a household on Device A
2. Note the 6-character code
3. Join the household from Device B using the code
4. Add items on Device A → should appear on Device B
5. Add items on Device B → should appear on Device A

## Troubleshooting

- **"google-services.json not found"**: Make sure file is in `android/app/` directory
- **Build errors**: Run `flutter clean && flutter pub get`
- **Permission denied**: Check Firestore security rules in Firebase Console
- **Items not syncing**: Check internet connection and Firebase Console logs
