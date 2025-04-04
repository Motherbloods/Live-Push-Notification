import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LiveSession {
  final DateTime startTime;
  final int? duration; // in minutes
  final String username;
  final String date;

  LiveSession({
    required this.startTime,
    this.duration,
    required this.username,
    required this.date,
  });

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      startTime: DateTime.parse(json['startTime']),
      duration: json['duration'],
      username: json['username'],
      date: json['date'],
    );
  }
  int get durationValue {
    return duration ?? 0; // Return 0 if duration is null
  }

  // Helper functions for formatting time and duration
  String get formattedDuration {
    if (duration == null) return 'In progress';

    int hours = duration! ~/ 60;
    int remainingMinutes = duration! % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  String get startTimeString {
    // Convert to GMT+7
    DateTime localTime = startTime.toUtc().add(Duration(hours: 7));
    return DateFormat('HH:mm').format(localTime);
  }

  String get endTimeString {
    if (duration == null) return 'TBD';

    // Convert to GMT+7
    DateTime localTime = startTime.toUtc().add(Duration(hours: 7));
    DateTime endTime = localTime.add(Duration(minutes: duration!));
    return DateFormat('HH:mm').format(endTime);
  }
}

Future<List<LiveSession>> fetchLiveSessions() async {
  final response =
      await http.get(Uri.parse("http://192.168.88.30:3000/livesessions"));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((json) => LiveSession.fromJson(json)).toList();
  } else {
    throw Exception("Failed to load live sessions");
  }
}
