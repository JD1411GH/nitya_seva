import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

GlobalKey<_DetailsState> detailsKey = GlobalKey<_DetailsState>();

class _DetailsState extends State<Details> {
  List<DataRow> _rows = [];

  @override
  initState() {
    super.initState();

    refresh();
  }

  Future<void> refresh() async {
    //     _createRow(['Prepared lamps', '', '', '']),
    // _createRow(['Unprepared lamps', '', '', '']),
    // _createRow(['Total lamps', '', '', ''], bold: true),
    // _createRow(['Lamp sale', '', '', '']),
    // _createRow(['Plate sale', '', '', '']),
    // _createRow(['Remaining lamps', '', '', ''], bold: true),

    setState(() {});
  }

  DataRow _createRow(List<String> data, {bool bold = false}) {
    return DataRow(
      cells: data
          .map((e) => DataCell(Text(
                e,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal),
              )))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DataTable(
          columns: [
            DataColumn(label: Text('')),
            DataColumn(label: Text('RKC')),
            DataColumn(label: Text('RRG')),
            DataColumn(label: Text('All')),
          ],
          rows: _rows,
        ),
      ),
    );
  }
}
