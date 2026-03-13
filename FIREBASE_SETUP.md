# Firebase Configuration Guide

This guide will help you set up Firebase for the Contact Manager app.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., "contact-manager")
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Set up Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database
5. Click "Enable"

## Step 3: Configure Security Rules

For development, you can use these permissive rules. **Update these for production!**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## Step 4: Android Configuration

1. In Firebase Console, go to Project Settings
2. Add an Android app with package name `com.example.assignment`
3. Download `google-services.json`
4. Place the file in `android/app/google-services.json`

### Update Android build files:

**android/build.gradle:**
```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

**android/app/build.gradle:**
```gradle
apply plugin: 'com.google.gms.google-services'
```

## Step 5: iOS Configuration

1. In Firebase Console, add an iOS app
2. Use bundle identifier from `ios/Runner.xcodeproj`
3. Download `GoogleService-Info.plist`
4. Place the file in `ios/Runner/GoogleService-Info.plist`

### Update iOS Podfile:

**ios/Podfile:**
```ruby
# Add this line at the top
require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'

target 'Runner' do
  # Add these pods
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
end
```

Then run:
```bash
cd ios
pod install
```

## Step 6: Web Configuration (Optional)

1. In Firebase Console, add a web app
2. Copy the Firebase configuration
3. Add it to your web configuration

## Step 7: Test the Connection

Run the app and verify:
- Firebase initializes successfully
- Contacts can be added/edited/deleted
- Real-time updates work across devices

## Production Security Rules

For production, use more restrictive rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own contacts
    match /contacts/{contactId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## Troubleshooting

### Common Issues:

**"No Firebase app initialized"**
- Check if `google-services.json` is in the correct location
- Verify Firebase initialization in main.dart

**"Permission denied" errors**
- Check Firestore security rules
- Ensure database is properly configured

**Build failures**
- Run `flutter clean && flutter pub get`
- Check for conflicting Firebase versions

### Debug Steps:

1. Check Firebase Console for project status
2. Verify configuration files are correctly placed
3. Check network connectivity
4. Review Firebase initialization logs
5. Test with a minimal Firebase example

## Additional Resources

- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Debugging Guide](https://firebase.google.com/docs/debug)
