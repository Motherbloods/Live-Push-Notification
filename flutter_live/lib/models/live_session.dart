class LiveSession {
  final DateTime startTime;
  final Duration duration;
  final String username;
  final String date;

  LiveSession({
    required this.startTime,
    required this.duration,
    required this.username,
    required this.date,
  });

  DateTime get endTime => startTime.add(duration);

  // Metode helper untuk konversi durasi ke format string
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  // Metode helper untuk mendapatkan jam mulai dan jam akhir sebagai string
  String get startTimeString {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get endTimeString {
    final end = endTime;
    return '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }
}

// Data contoh untuk aplikasi
List<LiveSession> getSampleData() {
  return [
    LiveSession(
      startTime: DateTime(2025, 4, 1, 8, 0),
      duration: Duration(hours: 1),
      username: 'user_live123',
      date: '01/04/2025',
    ),
    LiveSession(
      startTime: DateTime(2025, 4, 1, 0, 0),
      duration: Duration(hours: 1, minutes: 10),
      username: 'user_live123',
      date: '02/04/2025',
    ),
    LiveSession(
      startTime: DateTime(2025, 4, 4, 2, 0),
      duration: Duration(hours: 1, minutes: 20),
      username: 'user_live123',
      date: '02/04/2025',
    ),
    LiveSession(
      startTime: DateTime(2025, 3, 30, 10, 0),
      duration: Duration(hours: 2, minutes: 05),
      username: 'user_live123',
      date: '02/04/2025',
    ),
    LiveSession(
      startTime: DateTime(2025, 3, 30, 13, 0),
      duration: Duration(hours: 1, minutes: 10),
      username: 'user_live123',
      date: '02/04/2025',
    ),
    LiveSession(
      startTime: DateTime(2025, 4, 1, 12, 0),
      duration: Duration(hours: 1, minutes: 45),
      username: 'user_live123',
      date: '02/04/2025',
    ),
  ];
}
