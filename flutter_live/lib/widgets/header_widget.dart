import 'package:flutter/material.dart';
import 'package:flutter_live/models/live_session.dart';
import '../screens/live_session_screen.dart';

class HeaderWidget extends StatelessWidget {
  final String username;

  const HeaderWidget({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<LiveSession> liveSessions = getSampleData();
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF4A6CF7),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Username di kiri
          Flexible(
            child: Text(
              username,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Icon notifikasi di kanan
          GestureDetector(
            onTap: () {
              // Navigasi ke halaman LiveSessionsPage ketika ikon notifikasi diklik
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveSessionsPage(
                    liveSessions: liveSessions, // Daftar sesi live
                    username: username, // Nama pengguna
                  ),
                ),
              );
            },
            child: Icon(Icons.notifications),
          ),
        ],
      ),
    );
  }
}
