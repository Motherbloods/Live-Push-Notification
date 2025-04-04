import 'package:flutter/material.dart';
import '../models/live_session.dart';

class LiveDetailsWidget extends StatelessWidget {
  final List<LiveSession> liveSessions; // Sesi live pada tanggal yang dipilih
  final String username;
  final List<LiveSession> allSessions; // All sessions for this username

  const LiveDetailsWidget({
    Key? key,
    required this.liveSessions,
    required this.username,
    required this.allSessions, // This should be passed from the parent widget
  }) : super(key: key);

  // Mendapatkan sesi live terbaru dari daftar yang diberikan
  LiveSession? _getLatestSession(List<LiveSession> sessions) {
    if (sessions.isEmpty) return null;
    return sessions.reduce((a, b) => a.startTime.isAfter(b.startTime) ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    // Cari sesi live terakhir dari tanggal yang dipilih
    LiveSession? latestSessionOnSelectedDate = _getLatestSession(liveSessions);

    // Cari sesi live terakhir dari semua tanggal
    LiveSession? overallLatestSession = _getLatestSession(allSessions);

    // Gunakan sesi dari tanggal yang dipilih jika ada, jika tidak gunakan sesi terakhir dari keseluruhan
    LiveSession? sessionToShow =
        latestSessionOnSelectedDate ?? overallLatestSession;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Detail Live Terakhir untuk $username',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Status indikator yang menunjukkan apakah ini adalah data dari tanggal yang dipilih atau tanggal lain
              if (latestSessionOnSelectedDate == null &&
                  overallLatestSession != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    'Data tanggal lain',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Durasi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (sessionToShow != null)
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sessionToShow.date,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    sessionToShow.formattedDuration,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Tidak ada data untuk $username'),
            ),
          if (sessionToShow != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Mulai: ${sessionToShow.startTimeString} | Jam Akhir: ${sessionToShow.endTimeString}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 6),
                  if (latestSessionOnSelectedDate == null &&
                      overallLatestSession != null)
                    Text(
                      'Catatan: Tidak ada sesi live pada tanggal yang dipilih. Menampilkan data live terakhir.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
