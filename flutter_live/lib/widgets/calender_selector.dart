import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarSelector extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const CalendarSelector({
    Key? key,
    required this.selectedDay,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  _CalendarSelectorState createState() => _CalendarSelectorState();
}

class _CalendarSelectorState extends State<CalendarSelector> {
  bool _showCalendar = false;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDay;
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
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
