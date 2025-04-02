import 'package:flutter/material.dart';
import '../models/live_session.dart';

class LiveSessionsPage extends StatelessWidget {
  final List<LiveSession> liveSessions;
  final String username;

  const LiveSessionsPage({
    Key? key,
    required this.liveSessions,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Live $username'),
        elevation: 0,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (liveSessions.isEmpty) {
      return _buildEmptyState();
    }
    return _buildSessionsList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Tidak ada sesi live untuk $username.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: liveSessions.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final session = liveSessions[index];
        return _buildSessionCard(context, session);
      },
    );
  }

  Widget _buildSessionCard(BuildContext context, LiveSession session) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showSessionDetails(context, session),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Durasi: ${session.formattedDuration}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Tanggal: ${session.startTime.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Waktu: ${session.startTimeString} - ${session.endTimeString}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.info_outline),
                  label: Text('Detail'),
                  onPressed: () => _showSessionDetails(context, session),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionDetails(BuildContext context, LiveSession session) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.live_tv, color: Colors.red),
              SizedBox(width: 8),
              Text('Detail Sesi Live'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem(
                  icon: Icons.access_time,
                  label: 'Durasi',
                  value: session.formattedDuration,
                ),
                SizedBox(height: 12),
                _buildDetailItem(
                  icon: Icons.calendar_today,
                  label: 'Tanggal',
                  value: session.startTime.toLocal().toString().split(' ')[0],
                ),
                SizedBox(height: 12),
                _buildDetailItem(
                  icon: Icons.schedule,
                  label: 'Waktu Mulai',
                  value: session.startTimeString,
                ),
                SizedBox(height: 12),
                _buildDetailItem(
                  icon: Icons.schedule,
                  label: 'Waktu Selesai',
                  value: session.endTimeString,
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.close),
              label: Text('Tutup'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
