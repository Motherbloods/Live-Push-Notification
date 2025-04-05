import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:just_audio/just_audio.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:async';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'startAlarm':
        // Reset alarm state before playing
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('alarm_scheduled_state', false);
        await AlarmHandler._playAlarmInBackground();
        break;
    }
    return Future.value(true);
  });
}

class AlarmHandler {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static Timer? _alarmTimer;
  static Timer? _stateCheckTimer;

  static const String _alarmStateKey = 'alarm_scheduled_state';
  static const String _lastUpdateTimeKey = 'last_update_time';

  static Future<void> initialize() async {
    // Initialize Workmanager
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload == 'stop_alarm') {
          stopAlarm();
        }
      },
    );

    // Set up audio source
    await _audioPlayer.setAsset('assets/alarm.mp3');
    await _audioPlayer.setLoopMode(LoopMode.all);

    // Configure FCM for background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Configure FCM for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleFCMMessage(message);
    });

    // Start periodic state check
    _startStateCheck();
  }

  static void _startStateCheck() {
    _stateCheckTimer?.cancel();
    _stateCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _checkAndResetStaleState();
    });
  }

  static Future<void> _checkAndResetStaleState() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdateTime = prefs.getInt(_lastUpdateTimeKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // If last update was more than 30 seconds ago, reset state
    if (currentTime - lastUpdateTime > 30000) {
      await _setAlarmScheduled(false);
      print('State reset due to stale state detected');
    }
  }

  static Future<bool> _isAlarmScheduled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_alarmStateKey) ?? false;
  }

  static Future<void> _setAlarmScheduled(bool scheduled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alarmStateKey, scheduled);
    // Update last update time
    await prefs.setInt(
        _lastUpdateTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling background message: ${message.messageId}");
    await handleFCMMessage(message);
  }

  static Future<void> handleFCMMessage(RemoteMessage message) async {
    // Reset stale state before checking
    await _checkAndResetStaleState();

    final isScheduled = await _isAlarmScheduled();
    print('Current alarm scheduled state: $isScheduled');

    if (!isScheduled) {
      await _setAlarmScheduled(true);

      final prefs = await SharedPreferences.getInstance();
      final alarmTime =
          DateTime.now().add(Duration(seconds: 20)).millisecondsSinceEpoch;
      await prefs.setInt('nextAlarmTime', alarmTime);

      _scheduleAlarm();

      await _showNotification(
          "Alarm Dijadwalkan", "Alarm akan berbunyi dalam 1 menit",
          payload: 'schedule_info');
    }
  }

  static Future<void> _showNotification(String title, String body,
      {String payload = ''}) async {
    const androidDetails = AndroidNotificationDetails(
        'alarm_channel', 'Alarm Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        actions: [AndroidNotificationAction('stop_alarm', 'Stop Alarm')]);

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
        DateTime.now().millisecond, title, body, notificationDetails,
        payload: payload);
  }

  static void _scheduleAlarm() {
    _alarmTimer?.cancel();

    // Schedule work manager task
    Workmanager().registerOneOffTask('startAlarm', 'startAlarm',
        initialDelay: Duration(seconds: 20));

    // Also set regular timer as backup
    _alarmTimer = Timer(Duration(seconds: 20), () {
      _startAlarm();
    });
  }

  static Future<void> _startAlarm() async {
    try {
      // Reset alarm state before starting
      await _setAlarmScheduled(false);

      // Enable wakelock to keep screen on
      await WakelockPlus.enable();

      // Start foreground service
      if (await FlutterForegroundTask.canDrawOverlays) {
        await FlutterForegroundTask.startService(
          notificationTitle: "Alarm Berbunyi",
          notificationText: "Ketuk untuk menghentikan alarm",
          callback: _startForegroundTask,
        );
      } else {
        FlutterForegroundTask.openSystemAlertWindowSettings();
        await _showNotification("Izin Diperlukan",
            "Harap berikan izin overlay untuk alarm berfungsi dengan baik",
            payload: 'permission_required');
        return;
      }

      await _playAlarm();
    } catch (e) {
      print("Error memulai alarm: $e");
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _startForegroundTask() async {
    await _playAlarm();
  }

  static Future<void> _playAlarm() async {
    try {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();

      await _showNotification(
          "Alarm Berbunyi!", "Ketuk untuk menghentikan alarm",
          payload: 'stop_alarm');
    } catch (e) {
      print("Error memutar alarm: $e");
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _playAlarmInBackground() async {
    final player = AudioPlayer();
    await player.setAsset('assets/alarm.mp3');
    await player.setLoopMode(LoopMode.all);
    await player.play();
  }

  static Future<void> stopAlarm() async {
    await _setAlarmScheduled(false);

    // Stop audio
    await _audioPlayer.stop();

    // Cancel timers
    _alarmTimer?.cancel();

    // Cancel work manager tasks
    await Workmanager().cancelAll();

    // Stop foreground service
    await FlutterForegroundTask.stopService();

    // Disable wakelock
    await WakelockPlus.disable();

    // Clear stored alarm time
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nextAlarmTime');
  }
}
