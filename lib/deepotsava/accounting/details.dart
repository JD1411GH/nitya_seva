import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/sales/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

GlobalKey<_DetailsState> detailsKey = GlobalKey<_DetailsState>();

class _DetailsState extends State<Details> {
  List<DataRow> _rows = [];

  List<int> _preparedLamps = [0, 0, 0];
  List<int> _unpreparedLamps = [0, 0, 0];
  List<int> _totalLamps = [0, 0, 0];
  List<int> _lampSale = [0, 0, 0];
  List<int> _plateSale = [0, 0, 0];
  List<int> _remainingLamps = [0, 0, 0];
  Map<String, int> _amountPerModeRKC = {}; // 'UPI': 10, 'Cash': 20
  Map<String, int> _amountPerModeRRG = {}; // 'UPI': 10, 'Cash': 20

  @override
  initState() {
    super.initState();
  }

  Future<void> refresh() async {
    // clear everything before updating
    _rows.clear();
    _preparedLamps = [0, 0, 0];
    _unpreparedLamps = [0, 0, 0];
    _totalLamps = [0, 0, 0];
    _lampSale = [0, 0, 0];
    _plateSale = [0, 0, 0];
    _remainingLamps = [0, 0, 0];
    _amountPerModeRKC = {}; // 'UPI': 10, 'Cash': 20
    _amountPerModeRRG = {}; // 'UPI': 10, 'Cash': 20

    // read from FB
    List<DeepamStock> stocksRKC = await FBL().getStocks('RKC');
    List<DeepamStock> stocksRRG = await FBL().getStocks('RRG');
    List<DeepamSale> salesRKC = await FBL().getSales('RKC');
    List<DeepamSale> salesRRG = await FBL().getSales('RRG');

    // RKC data
    stocksRKC.forEach((stock) {
      _preparedLamps[0] += stock.preparedLamps;
      _unpreparedLamps[0] += stock.unpreparedLamps;
      _totalLamps[0] = _preparedLamps[0] + _unpreparedLamps[0];
    });
    salesRKC.forEach((sale) {
      _lampSale[0] += sale.count;
      _plateSale[0] += sale.plate;

      // amount per mode
      Map<String, int> am = {
        sale.paymentMode:
            (sale.count * sale.costLamp + sale.plate * sale.costPlate)
      };
      if (_amountPerModeRKC.containsKey(sale.paymentMode)) {
        _amountPerModeRKC[sale.paymentMode] =
            _amountPerModeRKC[sale.paymentMode]! + am[sale.paymentMode]!;
      } else {
        _amountPerModeRKC[sale.paymentMode] = am[sale.paymentMode]!;
      }
    });
    _remainingLamps[0] = _totalLamps[0] - _lampSale[0];

    // RRG data
    stocksRRG.forEach((stock) {
      _preparedLamps[1] += stock.preparedLamps;
      _unpreparedLamps[1] += stock.unpreparedLamps;
      _totalLamps[1] = _preparedLamps[1] + _unpreparedLamps[1];
    });
    salesRRG.forEach((sale) {
      _lampSale[1] += sale.count;
      _plateSale[1] += sale.plate;

      // amount per mode
      Map<String, int> am = {
        sale.paymentMode:
            (sale.count * sale.costLamp + sale.plate * sale.costPlate)
      };
      if (_amountPerModeRRG.containsKey(sale.paymentMode)) {
        _amountPerModeRRG[sale.paymentMode] =
            _amountPerModeRRG[sale.paymentMode]! + am[sale.paymentMode]!;
      } else {
        _amountPerModeRRG[sale.paymentMode] = am[sale.paymentMode]!;
      }
    });
    _remainingLamps[1] = _totalLamps[1] - _lampSale[1];

    // All data
    _preparedLamps[2] = _preparedLamps[0] + _preparedLamps[1];
    _unpreparedLamps[2] = _unpreparedLamps[0] + _unpreparedLamps[1];
    _totalLamps[2] = _totalLamps[0] + _totalLamps[1];
    _lampSale[2] = _lampSale[0] + _lampSale[1];
    _plateSale[2] = _plateSale[0] + _plateSale[1];
    _remainingLamps[2] = _remainingLamps[0] + _remainingLamps[1];

    // row for prepared lamps
    _rows.add(_createRow([
      'Prepared lamps',
      _preparedLamps[0].toString(),
      _preparedLamps[1].toString(),
      _preparedLamps[2].toString()
    ]));

    // row for unprepared lamps
    _rows.add(_createRow([
      'Unprepared lamps',
      _unpreparedLamps[0].toString(),
      _unpreparedLamps[1].toString(),
      _unpreparedLamps[2].toString()
    ]));

    // row for total lamps
    _rows.add(_createRow([
      'Total lamps',
      _totalLamps[0].toString(),
      _totalLamps[1].toString(),
      _totalLamps[2].toString()
    ], bold: true));

    // row for lamp sale
    _rows.add(_createRow([
      'Lamp sale',
      _lampSale[0].toString(),
      _lampSale[1].toString(),
      _lampSale[2].toString()
    ]));

    // row for plate sale
    _rows.add(_createRow([
      'Plate sale',
      _plateSale[0].toString(),
      _plateSale[1].toString(),
      _plateSale[2].toString()
    ]));

    // row for remaining lamps
    _rows.add(_createRow([
      'Remaining lamps',
      _remainingLamps[0].toString(),
      _remainingLamps[1].toString(),
      _remainingLamps[2].toString()
    ], bold: true));

    // rows for amount per mode through RKC
    List<int> totalAmount = [0, 0, 0];
    _amountPerModeRKC.forEach((mode, amount) {
      List<String> row = [];
      row.add('Amount through $mode');
      row.add(amount.toString());
      totalAmount[0] += amount;

      int rrgValue = 0;
      if (_amountPerModeRRG.containsKey(mode)) {
        rrgValue = _amountPerModeRRG[mode]!;
        _amountPerModeRRG.remove(mode);
      }
      row.add(rrgValue.toString());
      totalAmount[1] += rrgValue;

      row.add((amount + rrgValue).toString());
      totalAmount[2] += (amount + rrgValue);

      _rows.add(_createRow(row));
    });

    // rows for amount per mode through RRG
    _amountPerModeRRG.forEach((mode, amount) {
      List<String> row = [];
      row.add('Amount through $mode');
      row.add('0');
      row.add(amount.toString());
      row.add(amount.toString());

      _rows.add(_createRow(row));
    });

    // Total amount
    _rows.add(_createRow([
      'Total amount',
      totalAmount[0].toString(),
      totalAmount[1].toString(),
      totalAmount[2].toString()
    ], bold: true));

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
