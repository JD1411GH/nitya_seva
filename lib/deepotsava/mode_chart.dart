import 'package:flutter/material.dart';

class ModeChart extends StatefulWidget {
  const ModeChart({super.key});

  @override
  State<ModeChart> createState() => _ModeChartState();
}

class _ModeChartState extends State<ModeChart> {
  List<double> data = [0, 0, 0, 0];

  void updateData(String mode, int count) {
    setState(() {
      switch (mode) {
        case 'UPI':
          data[0] = count.toDouble();
          break;
        case 'Cash':
          data[1] = count.toDouble();
          break;
        case 'Card':
          data[2] = count.toDouble();
          break;
        case 'Gift':
          data[3] = count.toDouble();
          break;
        default:
          throw ArgumentError('Invalid mode: $mode');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBar('UPI', data[0], Colors.orange),
        _buildBar('Cash', data[1], Colors.green),
        _buildBar('Card', data[2], Colors.blue),
        _buildBar('Gift', data[3], Colors.grey),
      ],
    );
  }

  Widget _buildBar(String label, double value, Color color) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            SizedBox(width: 50, child: FittedBox(child: Text(label))),
            Expanded(
              child: Container(
                height: 20,
                color: color,
                width: value,
              ),
            ),
            SizedBox(width: 10),
            FittedBox(child: Text(value.toInt().toString())),
          ],
        ),
      ),
    );
  }
}
