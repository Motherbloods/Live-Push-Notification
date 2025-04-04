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
          // Username on the left
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

          // Notification icon on the right
          GestureDetector(
            onTap: () {
              // Fetch live sessions when notification icon is clicked
              _navigateToLiveSessionsPage(context);
            },
            child: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Method to fetch live sessions and navigate to LiveSessionsPage
  void _navigateToLiveSessionsPage(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Fetch live sessions from backend
      List<LiveSession> liveSessions = await fetchLiveSessions();

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to LiveSessionsPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveSessionsPage(
            liveSessions: liveSessions,
            username: username,
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load live sessions: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
