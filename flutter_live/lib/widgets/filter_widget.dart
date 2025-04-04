import 'package:flutter/material.dart';
import '../models/live_session.dart';
import 'package:intl/intl.dart';

class FiltersWidget extends StatelessWidget {
  final List<LiveSession> liveSessions;
  final String username;

  const FiltersWidget({
    Key? key,
    required this.liveSessions,
    required this.username,
  }) : super(key: key);

  // Calculate the longest session
  LiveSession? _getLongestSession() {
    if (liveSessions.isEmpty) return null;

    return liveSessions
        .reduce((a, b) => a.durationValue > b.durationValue ? a : b);
  }

  // Calculate the most frequent day for live sessions
  String _getMostFrequentDay() {
    if (liveSessions.isEmpty) return 'Tidak ada data';

    final dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];

    Map<int, int> dayFrequency = {};
    Map<int, int> dayDurations = {};
    for (var session in liveSessions) {
      final localTime = session.startTime.toUtc().add(Duration(hours: 7));
      int weekday = localTime.weekday;
      dayFrequency[weekday] = (dayFrequency[weekday] ?? 0) + 1;
      dayDurations[weekday] =
          (dayDurations[weekday] ?? 0) + session.durationValue;
    }

    int? mostFrequentWeekday;
    int maxFrequency = 0;
    int maxDuration = 0;

    dayFrequency.forEach((day, frequency) {
      // Choose the day with higher frequency
      if (frequency > maxFrequency) {
        maxFrequency = frequency;
        mostFrequentWeekday = day;
        maxDuration = dayDurations[day] ?? 0;
      }
      // If frequencies are equal, compare total duration
      else if (frequency == maxFrequency &&
          (dayDurations[day] ?? 0) > maxDuration) {
        mostFrequentWeekday = day;
        maxDuration = dayDurations[day] ?? 0;
      }
    });

    if (mostFrequentWeekday != null) {
      return dayNames[mostFrequentWeekday! - 1];
    } else {
      return 'Tidak ada data';
    }
  }

  // Function to format duration from minutes
  String _formatDuration(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  // Function to format time from DateTime
  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // Function to show detailed info for the longest session
  void _showLongestSessionDialog(BuildContext context) {
    LiveSession? longestSession = _getLongestSession();
    if (longestSession == null) return;

    DateTime localTime =
        longestSession.startTime.toUtc().add(Duration(hours: 7));

    // Calculate end time
    DateTime endTime = longestSession.duration != null
        ? localTime.add(Duration(minutes: longestSession.durationValue))
        : localTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detail Live Terlama untuk $username'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '⏳ Durasi: ${_formatDuration(longestSession.durationValue)}'),
              Text(
                  '📅 Tanggal: ${DateFormat('dd/MM/yyyy').format(longestSession.startTime)}'),
              Text(
                  '🕒 Waktu: ${_formatTime(longestSession.startTime)} - ${_formatTime(endTime)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Function to show detailed info for the most frequent day
  void _showMostFrequentDayDialog(BuildContext context) {
    String mostFrequentDay = _getMostFrequentDay();

    // Get live sessions on the most frequent day
    List<LiveSession> sessionsOnMostFrequentDay = liveSessions.where((session) {
      return session.startTime.weekday ==
          _getMostFrequentWeekdayIndex(mostFrequentDay);
    }).toList();

    // Find the longest session on that day
    LiveSession? longestSessionOnDay = sessionsOnMostFrequentDay.isEmpty
        ? null
        : sessionsOnMostFrequentDay
            .reduce((a, b) => a.durationValue > b.durationValue ? a : b);

    String firstSessionDate = sessionsOnMostFrequentDay.isNotEmpty
        ? DateFormat('dd/MM/yyyy')
            .format(sessionsOnMostFrequentDay.first.startTime)
        : 'Tidak ada data';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detail Hari Paling Sering untuk $username'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '📅 Hari yang paling sering live adalah **$mostFrequentDay**. pada tanggal $firstSessionDate.'),
              SizedBox(height: 10),
              Text('Sesi Live pada hari ini:'),
              // List of live sessions and their times
              ...sessionsOnMostFrequentDay.map((session) {
                return Text(
                    '${_formatTime(session.startTime)} - ${_formatDuration(session.durationValue)}');
              }).toList(),
              if (longestSessionOnDay != null) ...[
                SizedBox(height: 10),
                Text(
                    '⏳ Sesi Live Terpanjang pada hari ini: ${_formatDuration(longestSessionOnDay.durationValue)} - '
                    '🕒 Waktu: ${_formatTime(longestSessionOnDay.startTime)} - '
                    '${_formatTime(longestSessionOnDay.startTime.add(Duration(minutes: longestSessionOnDay.durationValue)))}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Function to get weekday index based on day name
  int _getMostFrequentWeekdayIndex(String dayName) {
    final dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return dayNames.indexOf(dayName) +
        1; // Add 1 because Dart weekdays start from 1 (Monday) to 7 (Sunday)
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik untuk $username',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),

          // Longest Live Session (Clickable)
          GestureDetector(
            onTap: () => _showLongestSessionDialog(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Paling Lama',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _getLongestSession() != null
                        ? _formatDuration(_getLongestSession()!.durationValue)
                        : '0h 0m',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A6CF7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),

          // Most Frequent Day (Clickable)
          GestureDetector(
            onTap: () => _showMostFrequentDayDialog(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hari Paling Sering',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _getMostFrequentDay(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A6CF7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
