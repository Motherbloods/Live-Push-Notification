import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/live_session.dart';

class CalendarSelector extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final List<LiveSession> liveSessions;

  const CalendarSelector({
    Key? key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.liveSessions,
  }) : super(key: key);

  @override
  _CalendarSelectorState createState() => _CalendarSelectorState();
}

class _CalendarSelectorState extends State<CalendarSelector> {
  bool _showCalendar = false;
  late DateTime _focusedDay;

  // Map to store total durations by day
  late Map<DateTime, int> _liveSessionDurationByDay;

  // Maximum duration found for any day (used for color scaling)
  late int _maxDuration;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDay;
    _calculateLiveSessionDurations();
  }

  @override
  void didUpdateWidget(CalendarSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.liveSessions != widget.liveSessions) {
      _calculateLiveSessionDurations();
    }
  }

  // Calculate total durations for each day and find maximum duration
  void _calculateLiveSessionDurations() {
    _liveSessionDurationByDay = {};

    // Group and sum durations by day
    for (var session in widget.liveSessions) {
      final localTime = session.startTime.toUtc().add(Duration(hours: 7));
      final dateKey = DateTime(
        localTime.year,
        localTime.month,
        localTime.day,
      );

      if (_liveSessionDurationByDay.containsKey(dateKey)) {
        _liveSessionDurationByDay[dateKey] =
            (_liveSessionDurationByDay[dateKey] ?? 0) + session.durationValue;
      } else {
        _liveSessionDurationByDay[dateKey] = session.durationValue;
      }
    }

    // Find maximum duration
    _maxDuration = 0;
    _liveSessionDurationByDay.values.forEach((duration) {
      if (duration > _maxDuration) {
        _maxDuration = duration;
      }
    });
  }

  // Get color intensity based on duration relative to max duration
  Color _getLiveSessionColor(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);

    if (!_liveSessionDurationByDay.containsKey(dateKey) || _maxDuration == 0) {
      return Colors.transparent;
    }

    final duration = _liveSessionDurationByDay[dateKey]!;
    // Calculate intensity (0.2 to 1.0) based on proportion of max duration
    final intensity = 0.2 + (0.8 * duration / _maxDuration);

    return Color(0xFF4A6CF7).withOpacity(intensity);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showCalendar = !_showCalendar;
            });
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Tanggal: ${DateFormat('dd/MM/yyyy').format(widget.selectedDay)} - ${DateFormat('dd/MM/yyyy').format(widget.selectedDay.add(Duration(days: 30)))}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Icon(Icons.calendar_today,
                      size: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
        if (_showCalendar) _buildCalendar(),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
            _showCalendar = false;
          });
          widget.onDaySelected(selectedDay);
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Color(0xFF4A6CF7),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xFF4A6CF7).withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 0, // Hide default markers
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Add custom calendar builders
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            // Get color for this day based on live sessions
            final liveSessionColor = _getLiveSessionColor(day);

            // Skip days without live sessions
            if (liveSessionColor.opacity == 0) {
              return null; // Use default builder
            }

            // Custom day cell for days with live sessions
            return Container(
              margin: const EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: liveSessionColor,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: liveSessionColor.opacity > 0.5
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
