import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/live_notifier_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/alarm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  await AlarmHandler.initialize();
  await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? fcmToken = "Token belum didapatkan";

  @override
  void initState() {
    super.initState();
    print("App initialized");
    getToken(); // Get token when app opens
    sendFCMToken();
  }

  Future<void> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      fcmToken = token;
    });
  }

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
      home: Scaffold(
        body: LiveNotifierScreen(username: username),
        floatingActionButton: FloatingActionButton(
          onPressed: AlarmHandler.stopAlarm,
          child: Icon(Icons.alarm_off),
          backgroundColor: Colors.red,
          tooltip: 'Stop Alarm',
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> sendFCMToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  var url = dotenv.env['URL'];
  if (token != null) {
    try {
      final response = await http.post(
        Uri.parse("$url/fcm"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token}),
      );

      print("ini token $token");
      if (response.statusCode == 200) {
        print("Token berhasil dikirim ke backend!");
      } else {
        print(
            "Gagal mengirim token. Status: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e, stackTrace) {
      print("Error mengirim token: $e");
      print("Stack trace: $stackTrace");
    }
  } else {
    print("Token FCM null, tidak bisa mengirim ke server");
  }
}
