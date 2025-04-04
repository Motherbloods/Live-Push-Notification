import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/live_session.dart';

class LiveChart extends StatelessWidget {
  final List<LiveSession> liveSessions;

  const LiveChart({
    Key? key,
    required this.liveSessions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate maximum duration in hours for chart scaling
    double maxDurationInHours = 4.0; // Default fallback value

    if (liveSessions.isNotEmpty) {
      // Find the maximum duration among all sessions
      final maxDuration = liveSessions
          .map((s) => s.durationValue)
          .reduce((a, b) => a > b ? a : b);
      // Convert to hours and round up to the next whole number for better display
      maxDurationInHours = (maxDuration / 60).ceil().toDouble();
      // Ensure we have at least a minimum scale (1 hour)
      maxDurationInHours = maxDurationInHours < 1 ? 1 : maxDurationInHours;
    }

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
                      maxY: maxDurationInHours, // Use dynamic maxY here
                      minY: 0, // Make sure bar chart starts from 0
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            if (groupIndex >= liveSessions.length) return null;

                            final session = liveSessions[groupIndex];
                            final hours = session.durationValue ~/ 60;
                            final minutes = session.durationValue % 60;

                            return BarTooltipItem(
                              '${session.startTimeString}\n$hours jam $minutes menit',
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
                                  offset: Offset(0, 5),
                                  child: Text(
                                    liveSessions[index].startTimeString,
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
                              // Dynamically generate hour labels based on maxDurationInHours
                              if (value % 1 == 0 &&
                                  value <= maxDurationInHours) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    value == 0 ? '0' : '${value.toInt()}h',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                );
                              }
                              return Container();
                            },
                            reservedSize: 30,
                            interval: maxDurationInHours <= 4
                                ? 1
                                : (maxDurationInHours / 4).ceil().toDouble(),
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

                        final durationInHours = session.durationValue / 60;

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
