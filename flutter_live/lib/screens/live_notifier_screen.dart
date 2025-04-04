import 'package:flutter/material.dart';
import '../models/live_session.dart';
import '../widgets/header_widget.dart';
import '../widgets/calender_selector.dart';
import '../widgets/live_chart.dart';
import '../widgets/filter_widget.dart';
import '../widgets/live_detail_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveNotifierScreen extends StatefulWidget {
  final String username;
  const LiveNotifierScreen({
    Key? key,
    required this.username,
  }) : super(key: key);
  @override
  _LiveNotifierScreenState createState() => _LiveNotifierScreenState();
}

class _LiveNotifierScreenState extends State<LiveNotifierScreen> {
  late DateTime _selectedDay;
  List<LiveSession>? _allLiveSessions; // Bisa null sebelum data diterima
  List<LiveSession>? _filteredSessions; // Bisa null sebelum filtering

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchLiveSessions(); // Ambil data dari API saat widget dimuat
  }

  Future<void> _fetchLiveSessions() async {
    try {
      // Gunakan fungsi yang sudah ada di file live_session.dart
      List<LiveSession> sessions = await fetchLiveSessions();

      setState(() {
        // Filter hanya sesi dengan username yang sesuai
        _allLiveSessions = sessions
            .where((session) => session.username == widget.username)
            .toList();
        _filterSessionsByDate(); // Filter setelah data diterima
      });
    } catch (e) {
      print("Error fetching live sessions: $e");
    }
  }

  // Filter sesi berdasarkan tanggal yang dipilih
  void _filterSessionsByDate() {
    if (_allLiveSessions == null) return; // Jangan filter jika data belum ada
    print(_allLiveSessions);
    setState(() {
      _filteredSessions = _allLiveSessions!.where((session) {
        final localTime = session.startTime.toUtc().add(Duration(hours: 7));
        final sessionDate = DateTime(
          localTime.year,
          localTime.month,
          localTime.day,
        );
        final selectedDate = DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
        );
        return sessionDate.isAtSameMomentAs(selectedDate);
      }).toList();
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = day;
      _filterSessionsByDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _allLiveSessions == null
          ? Center(child: CircularProgressIndicator()) // Loading state
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderWidget(username: widget.username),
                      SizedBox(height: 16),
                      CalendarSelector(
                        selectedDay: _selectedDay,
                        onDaySelected: _onDaySelected,
                        liveSessions: _allLiveSessions!,
                      ),
                      LiveSessionLegend(),
                      SizedBox(height: 16),
                      // We now pass filtered sessions to LiveChart
                      LiveChart(
                        liveSessions: _filteredSessions ?? [],
                      ),
                      SizedBox(height: 16),
                      FiltersWidget(
                        liveSessions: _allLiveSessions ?? [],
                        username: widget.username,
                      ),
                      SizedBox(height: 16),
                      // Pass both filtered sessions and all sessions for this username
                      LiveDetailsWidget(
                        liveSessions: _filteredSessions ?? [],
                        username: widget.username,
                        allSessions: _allLiveSessions ?? [],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class LiveSessionLegend extends StatelessWidget {
  const LiveSessionLegend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Durasi Live: ',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          SizedBox(width: 8),
          _buildLegendItem('Rendah', 0.2),
          SizedBox(width: 4),
          _buildLegendItem('Sedang', 0.5),
          SizedBox(width: 4),
          _buildLegendItem('Tinggi', 1.0),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, double opacity) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF4A6CF7).withOpacity(opacity),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
