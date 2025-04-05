import 'package:flutter/material.dart';
import 'screens/live_notifier_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    String username = '@${dotenv.env['USERNAME_TIKTOK']}';
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
