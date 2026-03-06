# Firebase Setup Instructions

## Important: Firebase Configuration Files

The following files contain sensitive Firebase credentials and are **NOT** included in this repository:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase.json`

## How to Set Up Firebase for This Project

### Option 1: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase:
   ```bash
   flutterfire configure
   ```

3. Follow the prompts to select your Firebase project

### Option 2: Manual Setup

1. Go to [Firebase Console](https://console.firebase.google.com)

2. Create or select your project

3. **For Android:**
   - Add Android app
   - Download `google-services.json`
   - Place in `android/app/`

4. **For iOS:**
   - Add iOS app
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/`

5. **For Web:**
   - Add Web app
   - Copy configuration

6. **Create firebase_options.dart:**
   - Copy `lib/firebase_options.dart.template` to `lib/firebase_options.dart`
   - Replace placeholder values with your actual Firebase credentials

## Firebase Services Used

- **Authentication:** Email/Password
- **Firestore:** Database for listings and user profiles
- **Storage:** (Optional) For images

## Firestore Security Rules

Make sure to set up these security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                              request.auth.uid == resource.data.createdBy;
    }
  }
}
```

## Need Help?

If you're setting up this project for the first time and need the Firebase credentials, contact the project owner.
