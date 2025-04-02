import 'package:flutter/material.dart';
import '../models/live_session.dart';

class FiltersWidget extends StatelessWidget {
  final List<LiveSession> liveSessions;
  final String username;

  const FiltersWidget({
    Key? key,
    required this.liveSessions,
    required this.username,
  }) : super(key: key);

  // Menghitung sesi live terpanjang
  LiveSession? _getLongestSession() {
    if (liveSessions.isEmpty) return null;

    return liveSessions
        .reduce((a, b) => a.duration.inMinutes > b.duration.inMinutes ? a : b);
  }

  // Menghitung hari yang paling sering untuk live
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
    Map<int, Duration> dayDurations = {};
    for (var session in liveSessions) {
      int weekday = session.startTime.weekday;
      dayFrequency[weekday] = (dayFrequency[weekday] ?? 0) + 1;
      dayDurations[weekday] =
          (dayDurations[weekday] ?? Duration()) + session.duration;
    }

    int? mostFrequentWeekday;
    int maxFrequency = 0;
    Duration maxDuration = Duration();

    dayFrequency.forEach((day, frequency) {
      // Memilih hari yang memiliki frekuensi lebih banyak
      if (frequency > maxFrequency) {
        maxFrequency = frequency;
        mostFrequentWeekday = day;
        maxDuration = dayDurations[day] ?? Duration();
      }
      // Jika frekuensinya sama, bandingkan durasi total
      else if (frequency == maxFrequency &&
          (dayDurations[day] ?? Duration()) > maxDuration) {
        mostFrequentWeekday = day;
        maxDuration = dayDurations[day] ?? Duration();
      }
    });

    if (mostFrequentWeekday != null) {
      return dayNames[mostFrequentWeekday! - 1];
    } else {
      return 'Tidak ada data';
    }
  }

  // Fungsi untuk menampilkan popup informasi sesi live terpanjang
  void _showLongestSessionDialog(BuildContext context) {
    LiveSession? longestSession = _getLongestSession();
    if (longestSession == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detail Live Terlama untuk $username'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⏳ Durasi: ${longestSession.formattedDuration}'),
              Text(
                  '📅 Tanggal: ${longestSession.startTime.toLocal().toString().split(' ')[0]}'), // Tampilkan tanggal dari startTime
              Text(
                  '🕒 Waktu: ${longestSession.startTimeString} - ${longestSession.endTimeString}'),
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

  // Fungsi untuk menampilkan popup informasi hari paling sering live
  void _showMostFrequentDayDialog(BuildContext context) {
    String mostFrequentDay = _getMostFrequentDay();

    // Mendapatkan sesi-sesi live pada hari yang paling sering
    List<LiveSession> sessionsOnMostFrequentDay = liveSessions.where((session) {
      return session.startTime.weekday ==
          _getMostFrequentWeekdayIndex(mostFrequentDay);
    }).toList();

    // Menentukan sesi dengan durasi terpanjang pada hari tersebut
    LiveSession? longestSessionOnDay = sessionsOnMostFrequentDay.isEmpty
        ? null
        : sessionsOnMostFrequentDay.reduce(
            (a, b) => a.duration.inMinutes > b.duration.inMinutes ? a : b);

    String firstSessionDate = sessionsOnMostFrequentDay.isNotEmpty
        ? sessionsOnMostFrequentDay.first.startTime
            .toLocal()
            .toString()
            .split(' ')[0]
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
              // Daftar sesi live dan jamnya
              ...sessionsOnMostFrequentDay.map((session) {
                return Text(
                    '${session.startTimeString} - ${session.formattedDuration}');
              }).toList(),
              if (longestSessionOnDay != null) ...[
                SizedBox(height: 10),
                Text(
                    '⏳ Sesi Live Terpanjang pada hari ini: ${longestSessionOnDay.formattedDuration} - '
                    '🕒 Waktu: ${longestSessionOnDay.startTimeString} - ${longestSessionOnDay.endTimeString}'),
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

  // Fungsi untuk mendapatkan index weekday berdasarkan nama hari
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
        1; // Menambahkan 1 karena weekday di Dart mulai dari 1 (Senin) sampai 7 (Minggu)
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

          // Live Paling Lama (Dapat diklik)
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
                    _getLongestSession()?.formattedDuration ?? '0h 0m',
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

          // Hari Paling Sering (Dapat diklik)
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
