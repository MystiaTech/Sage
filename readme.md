# Sage - Inventory Management App

Sage is a mobile application designed to help you track your grocery inventory, monitor expiration dates, and receive notifications when items are about to expire.

## Features

- Scan barcodes to add items
- Manual item entry
- Track inventory by location (pantry, fridge, freezer)
- View expiring items
- Set expiration dates (best before, use by)
- Estimate expiry based on shelf life
- Receive notification reminders for upcoming expirations

## Technologies Used

- React Native
- Expo
- SQLite database (expo-sqlite)
- Camera API (expo-camera)
- Notifications (expo-notifications)

## Getting Started

To run this project locally, you'll need to have Node.js and Expo CLI installed.

1. Clone the repository:
   ```bash
   git clone https://giteas.fullmooncyberworks.com/mystiatech/Sage.git
   ```

2. Navigate into the directory:
   ```bash
   cd Sage
   ```

3. Install dependencies:
   ```bash
   npm install
   ```

4. Start the development server:
   ```bash
   npm run start
   ```

5. Scan the QR code with your mobile device or use the Expo Go app to view the application.

## Project Structure

- `App.tsx` - Main application entry point
- `src/screens/` - All screen components
  - `Dashboard.tsx` - Home screen showing expiring items
  - `Inventory.tsx` - View inventory by location
  - `ScanScreen.tsx` - Barcode scanning functionality
  - `AddItem.tsx` - Add item manually or from scan
- `src/db.ts` - Database setup and queries
- `src/expiry.ts` - Expiry date calculation logic
- `src/notify.ts` - Notification scheduling

## Database Schema

The application uses SQLite for local data storage. The database has the following tables:

- `locations`: Stores location information (pantry, fridge, freezer)
- `products`: Stores product information including barcode, name, brand, and shelf life
- `stock`: Tracks individual stock items with quantity, location, acquisition date, expiration dates

## License

This project is licensed under the MIT License.
