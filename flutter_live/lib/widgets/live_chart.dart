import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/live_session.dart';

class LiveChart extends StatelessWidget {
  final List<LiveSession> liveSessions;

  const LiveChart({
    Key? key,
    required this.liveSessions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
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
            'Grafik Durasi Live',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: liveSessions.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data live session',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 4,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            if (groupIndex >= liveSessions.length) return null;

                            final session = liveSessions[groupIndex];
                            final hours = session.duration.inHours;
                            final minutes = session.duration.inMinutes % 60;

                            return BarTooltipItem(
                              '${DateFormat('HH:mm').format(session.startTime)}\n$hours jam $minutes menit',
                              TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < liveSessions.length) {
                                return Transform.translate(
                                  offset: Offset(0,
                                      5), // Geser ke bawah agar tidak kepotong
                                  child: Text(
                                    DateFormat('HH:mm')
                                        .format(liveSessions[index].startTime),
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                );
                              }
                              return Container();
                            },
                            reservedSize: 14,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              String text = '';
                              if (value == 0) text = '0';
                              if (value == 1) text = '1h';
                              if (value == 2) text = '2h';
                              if (value == 3) text = '3h';

                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(text,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10)),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: liveSessions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final session = entry.value;

                        final durationInHours = session.duration.inMinutes / 60;

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: durationInHours,
                              color: Color(0xFF4A6CF7),
                              width: 20,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(3),
                                bottom: Radius.circular(0),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 1,
                            dashArray: value == 0 ? null : [5, 5],
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
