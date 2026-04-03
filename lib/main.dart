import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/home_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> showWalkWarning(String dogName) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'walk_channel',
    'Walk Reminders',
    channelDescription: 'Notifications for missing dog walks',
    importance: Importance.max,
    priority: Priority.high,
    color: Colors.blue,
  );
  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(),
    macOS: DarwinNotificationDetails(),
  );

  await flutterLocalNotificationsPlugin.show(
    dogName.hashCode ^ 1, 
    'Time for a walk! 🐕',
    '$dogName needs to go outside!',
    platformDetails,
  );
}

Future<void> showFeedingWarning(String dogName) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'feeding_channel',
    'Feeding Reminders',
    channelDescription: 'Reminders to feed your dogs',
    importance: Importance.max,
    priority: Priority.high,
  );
  
  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(),
    macOS: DarwinNotificationDetails(),
  );
  
  await flutterLocalNotificationsPlugin.show(
    dogName.hashCode, 
    'Feed your dog! ⚠️',
    '$dogName needs to be fed right now!',
    platformDetails,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
  
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
    macOS: iosSettings,
  );
  
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const DogManagerApp());
}

class DogManagerApp extends StatefulWidget {
  const DogManagerApp({super.key});

  @override
  State<DogManagerApp> createState() => _DogManagerAppState();
}

class _DogManagerAppState extends State<DogManagerApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Manager',
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50], 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      home: HomeScreen(
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeChanged: _toggleTheme,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
