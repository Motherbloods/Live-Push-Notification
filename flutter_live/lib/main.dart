import 'package:flutter/material.dart';
import 'screens/live_notifier_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const String username = '@user123';
    return MaterialApp(
      title: 'Live Notifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
      ),
      home: LiveNotifierScreen(username: username),
      debugShowCheckedModeBanner: false,
    );
  }
}
