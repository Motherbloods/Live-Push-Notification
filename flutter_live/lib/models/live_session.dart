import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'duration': duration,
      'username': username,
      'date': date,
    };
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

class LiveSessionCache {
  static const String _cacheKey = 'cached_live_sessions';
  static const int _cacheDurationHours = 24; // Cache valid for 24 hours
  static const String _lastFetchTimeKey = 'last_fetch_time';

  // Save live sessions to local storage
  static Future<void> cacheLiveSessions(List<LiveSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert sessions to JSON
    final List<Map<String, dynamic>> jsonList =
        sessions.map((session) => session.toJson()).toList();

    // Save as JSON string
    await prefs.setString(_cacheKey, jsonEncode(jsonList));

    // Save current timestamp
    await prefs.setString(_lastFetchTimeKey, DateTime.now().toIso8601String());
  }

  // Get cached live sessions
  static Future<List<LiveSession>?> getCachedLiveSessions() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if cache exists
    if (!prefs.containsKey(_cacheKey) ||
        !prefs.containsKey(_lastFetchTimeKey)) {
      return null;
    }

    // Check if cache is still valid
    final lastFetchTime = DateTime.parse(prefs.getString(_lastFetchTimeKey)!);
    final now = DateTime.now();
    if (now.difference(lastFetchTime).inHours > _cacheDurationHours) {
      // Cache expired
      return null;
    }

    // Get cached data
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) return null;

    // Parse JSON
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => LiveSession.fromJson(json)).toList();
  }

  // Clear the cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_lastFetchTimeKey);
  }
}

Future<List<LiveSession>> fetchLiveSessions() async {
  try {
    // Try to get cached data first
    var connectivityResult = await Connectivity().checkConnectivity();
    bool isOffline = connectivityResult == ConnectivityResult.none;

    final cachedSessions = await LiveSessionCache.getCachedLiveSessions();

    if (isOffline) {
      if (cachedSessions != null) {
        print("Offline - using cached live sessions data");
        return cachedSessions;
      } else {
        throw Exception("No cached data available while offline");
      }
    }

    if (cachedSessions != null) {
      print("Using cached live sessions data");
      return cachedSessions;
    }

    // If no valid cache, fetch from API
    print("Fetching live sessions from API");
    var url = dotenv.env['URL'];

    final response = await http.get(
      Uri.parse("$url/livesessions"),
      headers: {"Connection": "close"},
    ).timeout(Duration(seconds: 20));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      final sessions = data.map((json) => LiveSession.fromJson(json)).toList();

      // Cache the fetched data for future use
      await LiveSessionCache.cacheLiveSessions(sessions);

      return sessions;
    } else {
      throw Exception("Failed to load live sessions");
    }
  } catch (e) {
    print("Error in fetchLiveSessions: $e");
    // If network error but we have cached data, use it
    final cachedSessions = await LiveSessionCache.getCachedLiveSessions();
    if (cachedSessions != null) {
      print("Using cached data due to network error");
      return cachedSessions;
    }
    throw Exception("Failed to load live sessions: $e");
  }
}
