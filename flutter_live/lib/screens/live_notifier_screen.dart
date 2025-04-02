import 'package:flutter/material.dart';
import '../models/live_session.dart';
import '../widgets/header_widget.dart';
import '../widgets/calender_selector.dart';
import '../widgets/live_chart.dart';
import '../widgets/filter_widget.dart';
import '../widgets/live_detail_widget.dart';

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
  late List<LiveSession> _allLiveSessions;
  late List<LiveSession> _filteredSessions;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    final allSampleData = getSampleData();
    _allLiveSessions = allSampleData
        .where((session) => session.username == widget.username)
        .toList();
    _filterSessionsByDate();
  }

  // Filter sesi berdasarkan tanggal yang dipilih
  void _filterSessionsByDate() {
    _filteredSessions = _allLiveSessions.where((session) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      final selectedDate = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
      );
      return sessionDate.isAtSameMomentAs(selectedDate);
    }).toList();
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
      body: SafeArea(
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
                ),
                SizedBox(height: 16),
                LiveChart(liveSessions: _filteredSessions),
                SizedBox(height: 16),

                // Mengubah Row menjadi Column agar widget tersusun atas-bawah
                FiltersWidget(
                  liveSessions: _allLiveSessions,
                  username: widget.username,
                ),
                SizedBox(height: 16),
                LiveDetailsWidget(
                  liveSessions: _filteredSessions,
                  username: widget.username,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
