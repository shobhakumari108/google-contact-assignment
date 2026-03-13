# Contact Manager App

A modern, feature-rich contact management application built with Flutter and Firebase. This app demonstrates professional-level Flutter development with proper MVC architecture, state management, and Material Design principles.

## Features

### Core Functionality
- **Contact Management**: Add, edit, delete, and view contacts
- **Favorites System**: Mark contacts as favorites for quick access
- **Search Functionality**: Search contacts by name, phone, email, or company
- **Call Integration**: Direct calling from the app
- **Email Integration**: Send emails directly from contact profiles

### UI/UX Features
- **Material Design 3**: Modern, intuitive interface following Material Design guidelines
- **Responsive Design**: Optimized for various screen sizes and devices
- **Smooth Animations**: Custom animations for enhanced user experience
- **Bottom Navigation**: Easy navigation between Contacts and Favorites
- **Pull-to-Refresh**: Refresh contact lists with gesture support

### Technical Features
- **MVC Architecture**: Clean separation of concerns
- **Firebase Integration**: Real-time data synchronization
- **State Management**: Provider pattern for efficient state management
- **Input Validation**: Comprehensive form validation
- **Error Handling**: User-friendly error messages and feedback

## Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── contact_model.dart    # Contact entity
├── views/                    # UI screens
│   ├── home_screen.dart      # Main navigation
│   ├── contacts_screen.dart  # Contacts list
│   ├── favorites_screen.dart # Favorites list
│   ├── add_contact_screen.dart # Add/Edit contact
│   └── contact_profile_screen.dart # Contact details
├── controllers/              # Business logic
│   └── contact_controller.dart # Contact management
├── services/                 # External services
│   └── firebase_service.dart  # Firebase operations
├── providers/                # State management
│   └── contact_provider.dart  # App state
├── utils/                    # Utilities
│   └── validators.dart       # Input validation
└── widgets/                  # Custom widgets
    └── animated_widgets.dart # Reusable animations
```

### MVC Pattern Implementation
- **Models**: Define data structure and business rules
- **Views**: Handle UI presentation and user interaction
- **Controllers**: Manage business logic and data operations

## Installation

### Prerequisites
- Flutter SDK (version 3.10.1 or higher)
- Dart SDK
- Firebase project
- Android Studio / VS Code

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd contact-manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Firestore Database
   - Enable Authentication (optional)
   - Download the configuration files:
     - For Android: `google-services.json` → `android/app/`
     - For iOS: `GoogleService-Info.plist` → `ios/Runner/`

4. **Platform-specific setup**

   **Android:**
   - Add `google-services` plugin to `android/build.gradle`
   - Add the plugin to `android/app/build.gradle`

   **iOS:**
   - Add Firebase SDK to `ios/Podfile`
   - Run `cd ios && pod install`

5. **Run the app**
   ```bash
   flutter run
   ```

## Usage Guide

### Adding Contacts
1. Tap the floating action button (+) on the home screen
2. Fill in the contact details:
   - Name (required)
   - Phone number (required)
   - Email (optional)
   - Company (optional)
   - Address (optional)
   - Notes (optional)
3. Toggle "Mark as Favorite" if needed
4. Tap "Save Contact"

### Managing Contacts
- **View**: Tap on any contact to see detailed information
- **Edit**: From contact profile, tap the edit button
- **Delete**: From contact profile, use the delete option
- **Call**: Tap the phone icon to call directly
- **Email**: Tap the email icon to send an email

### Using Favorites
- Navigate to the "Favorites" tab
- Mark contacts as favorites using the heart icon
- Favorite contacts appear in the dedicated favorites list

### Search Functionality
- Tap the search icon in the app bar
- Type to search across name, phone, email, and company fields
- Results update in real-time

## Dependencies

### Core Dependencies
- `flutter`: Flutter framework
- `firebase_core`: Firebase initialization
- `cloud_firestore`: Firestore database
- `firebase_auth`: Firebase authentication
- `provider`: State management
- `url_launcher`: Call and email integration

### UI Dependencies
- `cupertino_icons`: iOS-style icons
- `material_design_icons_flutter`: Extended icon library

### Utility Dependencies
- `uuid`: Unique ID generation
- `intl`: Date formatting
- `animations`: Animation utilities

## API Documentation

### FirebaseService
```dart
class FirebaseService {
  // Initialize Firebase
  Future<void> initialize()
  
  // Contact operations
  Future<List<Contact>> getContacts()
  Future<List<Contact>> getFavoriteContacts()
  Future<void> addContact(Contact contact)
  Future<void> updateContact(Contact contact)
  Future<void> deleteContact(String contactId)
  Future<void> toggleFavorite(String contactId, bool isFavorite)
  
  // Stream operations
  Stream<List<Contact>> getContactsStream()
  Stream<List<Contact>> getFavoriteContactsStream()
}
```

### ContactController
```dart
class ContactController extends ChangeNotifier {
  // Getters
  List<Contact> get contacts
  List<Contact> get favoriteContacts
  bool get isLoading
  String? get error
  
  // Contact operations
  Future<void> addContact(Contact contact)
  Future<void> updateContact(Contact contact)
  Future<void> deleteContact(String contactId)
  Future<void> toggleFavorite(String contactId, bool isFavorite)
  Future<void> refreshContacts()
  
  // Search functionality
  List<Contact> searchContacts(String query)
  List<Contact> searchFavoriteContacts(String query)
}
```

## Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/contact_controller_test.dart

# Generate test coverage
flutter test --coverage
```

### Test Coverage
- Unit tests for controllers
- Widget tests for UI components
- Integration tests for user flows

## Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build iOS app
flutter build ios --release
```

## Performance Optimizations

### Implemented Optimizations
- **Lazy Loading**: Contacts load on demand
- **Stream-based Updates**: Real-time data synchronization
- **Efficient State Management**: Provider pattern minimizes rebuilds
- **Image Caching**: Profile pictures cached locally
- **Optimized Animations**: 60fps smooth animations

### Memory Management
- Proper disposal of controllers and streams
- Efficient list rendering with ListView.builder
- Resource cleanup in dispose methods

## Troubleshooting

### Common Issues

**Firebase Connection Issues**
- Verify Firebase configuration files are correctly placed
- Check internet connectivity
- Ensure Firebase project is properly configured

**Build Issues**
- Run `flutter clean` and `flutter pub get`
- Check for platform-specific dependencies
- Verify Flutter and SDK versions

**Performance Issues**
- Monitor memory usage with Flutter Inspector
- Check for unnecessary widget rebuilds
- Optimize image sizes and resources

## Contributing

### Development Guidelines
1. Follow Flutter/Dart coding standards
2. Write tests for new features
3. Update documentation for API changes
4. Use meaningful commit messages
5. Ensure code passes all linting rules

### Code Style
- Use `dart format` for code formatting
- Follow `flutter_lints` rules
- Write clear, descriptive comments
- Use meaningful variable and function names

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the API documentation

## Future Enhancements

### Planned Features
- [ ] Contact groups and categories
- [ ] Import/export contacts
- [ ] Dark mode support
- [ ] Contact backup and restore
- [ ] Advanced search filters
- [ ] Contact history tracking
- [ ] Social media integration
- [ ] Custom themes
- [ ] Voice search
- [ ] Contact widgets

### Technical Improvements
- [ ] Offline data synchronization
- [ ] Performance monitoring
- [ ] Crash reporting
- [ ] Analytics integration
- [ ] A/B testing framework
