import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final String temp;
  final IconData icon;
  const HourlyForecastItem({
    super.key,
    required this.icon,
    required this.time,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(80)),
        child: Column(
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow:TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Icon(icon, size: 40),
            SizedBox(height: 8),
            Text(temp, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
