import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';

class Pie extends StatefulWidget {
  const Pie({super.key});

  @override
  State<Pie> createState() => _PieState();
}

class _PieState extends State<Pie> {
  List<bool> _selectedRadio = [true, false, false];
  final List<String> _radioText = ['RKC', 'RRG', 'Sum'];

  Map<String, int> _pieText = {};
  Map<String, int> _pieValue = {};

  List<Map<String, int>> salePerMode = [{}, {}];

  @override
  initState() {
    super.initState();

    // set dummy pie data
    Const().paymentModes.forEach((mode, details) {
      _pieText[mode] = 0;
      _pieValue[mode] = 0;
    });

    // read all data
    FBL().getSales(_radioText[0]).then((List<DeepamSale> sales) {
      sales.forEach((sale) {
        salePerMode[0][sale.paymentMode] =
            (salePerMode[0][sale.paymentMode] ?? 0) + sale.count;
      });

      setState(() {
        // setting some default values for chart
        _pieText = salePerMode[0];

        int sum = 0;
        salePerMode[0].forEach((mode, count) {
          sum += count;
        });

        salePerMode[0].forEach((mode, count) {
          _pieValue[mode] = (count / sum * 100).round();
        });
      });
    });
    FBL().getSales(_radioText[1]).then((List<DeepamSale> sales) {
      sales.forEach((sale) {
        salePerMode[1][sale.paymentMode] =
            (salePerMode[1][sale.paymentMode] ?? 0) + sale.count;
      });
    });
  }

  Widget _createRadioButtons(BuildContext context) {
    return ToggleButtons(
      children: [
        Text(_radioText[0]),
        Text(_radioText[1]),
        Text(_radioText[2]),
      ],
      constraints: BoxConstraints(minHeight: 30, minWidth: 50),
      isSelected: _selectedRadio,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _selectedRadio.length; i++) {
            _selectedRadio[i] = i == index;
          }
        });
      },
    );
  }

  PieChartSectionData _createPieSection(mode) {
    Color color = Colors.grey;
    color = Const().paymentModes[mode]?['color'] as Color;

    return PieChartSectionData(
      color: color,
      value: _pieValue[mode]!.toDouble(),
      title: _pieText[mode].toString(),
      radius: 40,
      titleStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: _pieValue[mode]! > 9
            ? Colors.white
            : Theme.of(context).textTheme.bodyLarge!.color,
      ),
      titlePositionPercentageOffset: _pieValue[mode]! > 9 ? 0.5 : 1.2,
    );
  }

  Widget _createPieChart(BuildContext context) {
    List<PieChartSectionData> sections = [];

    Const().paymentModes.forEach((mode, details) {
      if (_pieValue[mode] != 0) {
        sections.add(_createPieSection(mode));
      }
    });

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 8,
      ),
    );
  }

  Widget _createPieLegends() {
    List<Widget> children = [];

    Const().paymentModes.forEach((mode, details) {
      if (_pieValue[mode] != 0) {
        children.add(_createLegendItem(details['color'] as Color, mode));
      }
    });

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _createLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // radio buttons
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_createRadioButtons(context)]),

            const SizedBox(height: 8),

            // pie chart
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: _createPieChart(context),
                ),
                const SizedBox(width: 50),
                _createPieLegends(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
