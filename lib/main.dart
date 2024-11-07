import 'package:flutter/material.dart';
import 'package:reminderapp_with_sqflite/screens/home_screen.dart';
import 'package:reminderapp_with_sqflite/services/notifications_helper.dart';

import 'database/db_helper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDb();
  await NotificationsHelper.initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Montserrat',
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
