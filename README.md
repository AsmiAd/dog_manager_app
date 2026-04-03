# Dog Manager App

A comprehensive Flutter application for managing your dogs' daily care, health, and activities. Keep track of feeding schedules, walking routines, health status, and receive timely notifications to ensure your pets stay happy and healthy.

## Features

### 🐕 Dog Management
- **Add Dogs**: Create profiles for each dog with name, breed, weight, birth date, and photo
- **Health Tracking**: Monitor health status (Healthy, Sick, etc.) and mood
- **Feeding Schedule**: Set custom feeding intervals and track last feeding times
- **Walking Routine**: Configure walking intervals and monitor exercise needs
- **Notes**: Add personal notes for each dog

### 📊 Analytics & Reports
- **Monthly Reports**: Generate reports showing happy days, sick days, lazy days, and missed feedings
- **History Tracking**: Daily mood and feeding records
- **Visual Insights**: Charts and statistics for better pet care decisions

### 🔔 Smart Notifications
- **Feeding Reminders**: Automatic notifications when it's time to feed your dog
- **Walking Alerts**: Reminders for walks based on your set intervals
- **Customizable**: Different notification channels for feeding and walking

### 🎨 User Experience
- **Dark/Light Theme**: Toggle between themes for comfortable viewing
- **Search & Filter**: Find dogs quickly with search and filter options
- **Sort Options**: Sort dogs by name, last fed time, or mood
- **Responsive Design**: Optimized for mobile devices

## Screenshots

*(Add screenshots here when available)*

## Installation

### Prerequisites
- Flutter SDK (version 3.11.0 or higher)
- Dart SDK (version 3.11.0 or higher)
- Android Studio or VS Code with Flutter extensions

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/AsmiAd/dog_manager_app.git
   cd dog_manager_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Production
- **Android APK**:
  ```bash
  flutter build apk --release
  ```
- **iOS**:
  ```bash
  flutter build ios --release
  ```

## Usage

### Getting Started
1. Launch the app
2. Add your first dog using the "+" button
3. Set feeding and walking intervals
4. The app will automatically send notifications when care is needed

### Managing Dogs
- **Add Dog**: Tap the add button to create a new dog profile
- **View Details**: Tap on a dog card to see detailed information and history
- **Edit Dog**: Use the edit button in dog details to modify information
- **Delete Dog**: Swipe or use the delete option to remove a dog

### Notifications
- Grant notification permissions when prompted
- Customize notification settings in your device settings
- Two channels: "Feeding Reminders" and "Walk Reminders"

## Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point and notifications
├── models/
│   ├── dog.dart             # Dog model with care logic
│   └── dog_history.dart     # Daily history tracking
└── screens/
    ├── home_screen.dart     # Main dashboard
    ├── add_dog_screen.dart  # Add/edit dog form
    ├── dog_detail_screen.dart # Dog profile view
    └── report_screen.dart   # Analytics and reports
```

### Key Components

#### Models
- **Dog**: Core model containing all dog information, care schedules, and business logic
- **DogHistory**: Tracks daily mood and feeding status for reporting

#### Screens
- **HomeScreen**: Displays dog list with search, filter, and sort capabilities
- **AddDogScreen**: Form for creating and editing dog profiles
- **DogDetailScreen**: Detailed view with history and editing options
- **ReportScreen**: Monthly analytics and care statistics

### State Management
- Uses `SharedPreferences` for local data persistence
- Simple state management with `setState` for UI updates
- JSON serialization for data storage

## Dependencies

### Core Dependencies
- **flutter**: UI framework
- **shared_preferences**: Local data storage
- **image_picker**: Photo selection for dog profiles
- **flutter_local_notifications**: Push notifications for reminders

### Development Dependencies
- **flutter_lints**: Code linting
- **flutter_launcher_icons**: App icons
- **flutter_native_splash**: Splash screen

## API Reference

### Dog Model
```dart
class Dog {
  final String id;
  final String name;
  final String mood;
  final String notes;
  final DateTime? lastFedTime;
  final String healthStatus;
  final int feedingInterval;
  final List<DogHistory> history;
  final String? imagePath;
  final double? weight;
  final DateTime? birthDate;
  final DateTime? lastWalkedTime;
  final int walkInterval;

  bool get needsFeeding;  // Check if feeding is due
  bool get needsWalking;  // Check if walking is due
  Map<String, int> generateMonthlyReport();  // Generate care statistics
}
```

### Notification Functions
```dart
Future<void> showWalkWarning(String dogName);
Future<void> showFeedingWarning(String dogName);
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email [your-email@example.com] or create an issue in the repository.

## Roadmap

- [ ] Cloud backup and sync
- [ ] Vet appointment scheduling
- [ ] Medication tracking
- [ ] Breed-specific care recommendations
- [ ] Social features for dog owners
- [ ] Integration with fitness trackers
