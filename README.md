# Kigali City Services App

A Flutter application for discovering and managing local services in Kigali, Rwanda. Users can browse service listings, add their own services, and interact with service providers through calls and directions.

## Architecture Overview

The app follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── models/              # Data models (Listing, User, etc.)
├── services/            # Business logic (Firebase, Maps, etc.)
├── providers/           # State management (Provider package)
├── screens/             # UI screens
├── widgets/             # Reusable UI components
└── core/                # Utilities (validators, constants)
```

### Data Flow

**Firestore → Services → Providers → UI Widgets**

1. **Firestore Collections**: Raw data stored in Firebase
2. **Services**: Fetch and transform data from Firestore
3. **Providers**: Manage app state and notify listeners
4. **Widgets**: Display data and handle user interactions

## Firebase Setup

### Collections Structure

#### `users` Collection
```
users/
├── {userId}/
│   ├── email: string
│   ├── name: string
│   ├── phone: string
│   ├── createdAt: timestamp
│   └── emailVerified: boolean
```

#### `listings` Collection
```
listings/
├── {listingId}/
│   ├── userId: string (reference to user)
│   ├── title: string
│   ├── description: string
│   ├── category: string
│   ├── latitude: number
│   ├── longitude: number
│   ├── phone: string
│   ├── createdAt: timestamp
│   └── imageUrl: string (optional)
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == userId;
      allow update, delete: if request.auth.uid == userId;
    }
    
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

### Firebase Configuration

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Enable Firestore Database
4. Download `google-services.json` and place in `android/app/src/main/`
5. Run `flutterfire configure` to generate `firebase_options.dart`

**Note**: Firebase configuration files are in `.gitignore`. Create your own Firebase project for development.

## State Management

The app uses the **Provider** package for state management with three main providers:

### AuthProvider
Manages user authentication state and operations.

```dart
// Key methods:
- signUp(email, password, name, phone)
- signIn(email, password)
- signOut()
- checkEmailVerification()
- clearError()
```

**State**:
- `currentUser`: Currently logged-in user
- `isLoading`: Loading state during auth operations
- `error`: Error messages

### ListingProvider
Manages listings data and real-time updates.

```dart
// Key methods:
- listenToAllListings()      // All listings in Kigali
- listenToUserListings()     // Current user's listings
- createListing(data)
- updateListing(id, data)
- deleteListing(id)
- getFilteredListings(query) // Search/filter
```

**State**:
- `allListings`: All service listings
- `userListings`: Current user's listings
- `isLoading`: Loading state

### MapProvider
Manages map state and location data.

```dart
// Key methods:
- searchLocation(query)
- setSelectedLocation(lat, lng)
```

**State**:
- `selectedLocation`: Currently selected map location
- `searchResults`: Location search results

## Navigation Structure

The app uses a centralized routing system in the `App` widget:

```
App (StreamBuilder on authStateChanges)
├── Not Logged In → LoginScreen
├── Logged In + Not Verified → VerifyEmailScreen
└── Logged In + Verified → MainNavigationScreen
    ├── DirectoryScreen (All listings)
    ├── MyListingsScreen (User's listings)
    ├── AddEditListingScreen (Create/Edit)
    └── MapViewScreen (Browse on map)
```

### Key Navigation Points

- **Login/Signup**: Automatic routing after auth state changes
- **Email Verification**: Polls every 3 seconds, auto-logs in when verified
- **Listing Detail**: Bottom navigation bar for easy access to Directory, My Listings, and Map
- **Add/Edit Listing**: Returns to previous screen after save

## Key Features

### 1. Service Discovery
- Browse all services in Kigali
- Search and filter by category
- View service details with location

### 2. Service Management
- Create new service listings
- Edit existing listings
- Delete listings
- View your listings

### 3. Location Features
- View services on interactive map (OpenStreetMap)
- Get directions to service location
- Call service provider directly
- Manual coordinate entry with "Use Current Location" button

### 4. Authentication
- Email/password signup and login
- Email verification required
- Password reset functionality
- Persistent login

## Default Coordinates

The app uses Kigali city center as default location:
- **Latitude**: -1.9441
- **Longitude**: 30.0619

## Map System

The app uses **flutter_map** with OpenStreetMap tiles (no API key required):

```dart
// Tile URL
https://tile.openstreetmap.org/{z}/{x}/{y}.png
```

Features:
- Interactive map with zoom/pan
- Location search
- Marker placement
- Directions integration

## Android Permissions

Required permissions in `AndroidManifest.xml`:
- `CALL_PHONE`: Make phone calls
- `INTERNET`: Network access
- `ACCESS_FINE_LOCATION`: Precise location (optional)
- `ACCESS_COARSE_LOCATION`: Approximate location (optional)

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Firebase project
- Android SDK / iOS SDK

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   ```bash
   flutterfire configure
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure Details

### Models (`lib/models/`)
- `user_model.dart`: User data structure
- `listing_model.dart`: Service listing data structure

### Services (`lib/services/`)
- `auth_service.dart`: Firebase authentication
- `listing_service.dart`: Firestore listings operations
- `map_service.dart`: Maps and directions

### Providers (`lib/providers/`)
- `auth_provider.dart`: Authentication state
- `listing_provider.dart`: Listings state
- `map_provider.dart`: Map state

### Screens (`lib/screens/`)
- `auth/`: Login, signup, email verification, password reset
- `directory/`: Browse all listings
- `listing/`: Listing details, add/edit listings
- `map/`: Map view with search
- `main_navigation_screen.dart`: Bottom navigation

### Widgets (`lib/widgets/`)
- `custom_textfield.dart`: Reusable text input
- `loading_widget.dart`: Loading indicator
- `map_widget.dart`: Reusable map component

## Real-Time Updates

The app uses Firestore listeners for real-time data synchronization:

```dart
// In MainNavigationScreen.initState()
listenToAllListings()   // Updates when any listing changes
listenToUserListings()  // Updates when user's listings change
```

Changes are automatically reflected in the UI through Provider's `notifyListeners()`.

## Error Handling

- Authentication errors displayed in error containers
- Listing operation errors shown via SnackBars
- Loading states prevent duplicate submissions
- Validation on all user inputs

## Theme

- **Primary Color**: Blue (#2196F3)
- **Accent Color**: Orange (#FF9800)
- **Background**: Light grey (#F5F5F5)
- **Text**: Black on light backgrounds
- **Mode**: Light theme for better visibility

## Future Enhancements

- Image uploads for listings
- User ratings and reviews
- Advanced filtering (distance, price range)
- Favorites/bookmarks
- Push notifications
- User profile management

## Troubleshooting

### App shows blank screen after login
- Check email verification status
- Ensure Firestore rules allow read access
- Verify Firebase configuration

### Listings not appearing
- Check Firestore collections exist
- Verify user has permission to read listings
- Check real-time listeners are active

### Map not loading
- Verify internet connection
- Check OpenStreetMap tile server status
- Ensure location permissions granted

## Support

For issues or questions, refer to:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
