import 'package:flutter/material.dart';

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
