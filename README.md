# Contact Manager App

A modern, feature-rich contact management application built with Flutter and SQLite for offline data management. This app demonstrates professional-level Flutter development with proper MVC architecture, state management, and Material Design principles.

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
- **Instant Feedback**: Real-time UI updates for all actions

### Technical Features
- **MVC Architecture**: Clean separation of concerns
- **SQLite Database**: Local offline data storage
- **State Management**: Provider pattern for efficient state management
- **Input Validation**: Comprehensive form validation
- **Error Handling**: User-friendly error messages and feedback
- **Memory Management**: Proper resource disposal and cleanup



### MVC Pattern Implementation
- **Models**: Define data structure and business rules
- **Views**: Handle UI presentation and user interaction
- **Controllers**: Manage business logic and data operations

## Installation

### Prerequisites
- Flutter SDK (version 3.10.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/shobhakumari108/google-contact-assignment.git
  cd google-contact-assignment
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Platform-specific setup**

   **Android:**
   - Add phone permission to `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <uses-permission android:name="android.permission.CALL_PHONE" />
     ```

   **iOS:**
   - Add phone permission to `ios/Runner/Info.plist`:
     ```xml
     <key>NSContactsUsageDescription</key>
     <string>This app needs access to contacts to manage them</string>
     ```
4. **Run the app**
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
- `sqflite`: SQLite database for local storage
- `path`: Path manipulation for database
- `provider`: State management
- `url_launcher`: Call and email integration

### UI Dependencies
- `cupertino_icons`: iOS-style icons
- `material_design_icons_flutter`: Extended icon library

### Utility Dependencies
- `uuid`: Unique ID generation
- `intl`: Date formatting
- `animations`: Animation utilities

## 🎯 Key Achievements

- ✅ **Complete Offline Functionality**: Works without internet using SQLite
- ✅ **Material Design 3**: Modern, intuitive UI following latest guidelines
- ✅ **Instant UI Updates**: Real-time feedback for all user interactions
- ✅ **Comprehensive CRUD Operations**: Full contact management lifecycle
- ✅ **Advanced Search & Filter**: Powerful search across multiple fields
- ✅ **Responsive Design**: Optimized for all screen sizes and devices
- ✅ **Clean MVC Architecture**: Proper separation of concerns
- ✅ **Memory Efficient**: Optimized performance with proper resource management
- ✅ **User-Friendly**: Intuitive navigation and smooth interactions
- ✅ **Error Handling**: Robust error management with user feedback
- ✅ **Input Validation**: Comprehensive form validation
- ✅ **Favorites System**: Quick access to important contacts
- ✅ **Call & Email Integration**: Native device integration
- ✅ **Smooth Animations**: Professional transitions and micro-interactions
