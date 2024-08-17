import 'package:flutter/material.dart';

class DistributionTiles extends StatefulWidget {
  @override
  _DistributionTilesState createState() => _DistributionTilesState();
}

class _DistributionTilesState extends State<DistributionTiles> {
  final List<Map<String, String>> logs = [
    {'time': '08:00', 'count': '5'},
    {'time': '09:00', 'count': '3'},
    {'time': '10:00', 'count': '8'},
    {'time': '10:00', 'count': '8'},
    {'time': '10:00', 'count': '8'},
    // Add more logs as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return _buildTile(logs[index]['time']!, logs[index]['count']!);
        },
      ),
    );
  }

  Widget _buildTile(String time, String count) {
    return Container(
      // decoration for the tile
      width: 100,
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // time display
          Text(
            time,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),

          // laddu count display
          Container(
            padding: EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black,
                width: 2.0,
              ),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
