import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/deepotsava/sales/datatypes.dart';

class Summary extends StatefulWidget {
  final String stall;
  const Summary({super.key, required this.stall});

  @override
  State<Summary> createState() => _SummaryState();
}

GlobalKey<_SummaryState> summaryKey = GlobalKey<_SummaryState>();

class _SummaryState extends State<Summary> {
  int _preparedLampsReceivedCount = 0;
  int _unpreparedLampsReceivedCount = 0;
  int _platesReceivedCount = 0;
  int _totalLampsServedCount = 0;
  int _totalLampsServedAmount = 0;
  int _discardedLampsCount = 0;
  int _totalPlatesServedCount = 0;
  int _totalPlatesServedAmount = 0;
  Map<String, int> _paymentModesCount = {};
  Map<String, int> _paymentModesAmount = {};

  @override
  void initState() {
    super.initState();

    refresh();
  }

  Future<void> refresh() async {
    List<DeepamStock> stocks = await FBL().getStocks(widget.stall);
    List<DeepamSale> sales = await FBL().getSales(widget.stall);

    setState(() {
      // reset everything
      _preparedLampsReceivedCount = 0;
      _unpreparedLampsReceivedCount = 0;
      _platesReceivedCount = 0;
      _totalLampsServedCount = 0;
      _totalLampsServedAmount = 0;
      _discardedLampsCount = 0;
      _totalPlatesServedCount = 0;
      _totalPlatesServedAmount = 0;
      _paymentModesCount = {};
      _paymentModesAmount = {};

      // fill stock data
      stocks.forEach((stock) {
        _preparedLampsReceivedCount += stock.preparedLamps;
        _unpreparedLampsReceivedCount += stock.unpreparedLamps;
        _platesReceivedCount += stock.plates;
      });

      // fill sales data
      sales.forEach((sale) {
        _totalLampsServedCount += sale.count;
        _totalLampsServedAmount += (sale.count * sale.costLamp);
        _totalPlatesServedCount += sale.plate;
        _totalPlatesServedAmount += (sale.plate * sale.costPlate);

        if (_paymentModesCount.containsKey(sale.paymentMode)) {
          _paymentModesCount[sale.paymentMode] =
              _paymentModesCount[sale.paymentMode]! + 1;
          _paymentModesAmount[sale.paymentMode] =
              _paymentModesAmount[sale.paymentMode]! +
                  (sale.costLamp * sale.count + sale.costPlate * sale.plate);
        } else {
          _paymentModesCount[sale.paymentMode] = 1;
          _paymentModesAmount[sale.paymentMode] =
              (sale.costLamp * sale.count + sale.costPlate * sale.plate);
        }
      });
    });
  }

  void addStock(DeepamStock stock) {
    setState(() {
      _preparedLampsReceivedCount += stock.preparedLamps;
      _unpreparedLampsReceivedCount += stock.unpreparedLamps;
      _platesReceivedCount += stock.plates;
    });
  }

  void deleteStock(DeepamStock stock) {
    setState(() {
      _preparedLampsReceivedCount -= stock.preparedLamps;
      _unpreparedLampsReceivedCount -= stock.unpreparedLamps;
      _platesReceivedCount -= stock.plates;
    });
  }

  void addSale(DeepamSale sale) {
    setState(() {
      _totalLampsServedCount += sale.count;
      _totalLampsServedAmount += (sale.count * sale.costLamp);
      _totalPlatesServedCount += sale.plate;
      _totalPlatesServedAmount += (sale.plate * sale.costPlate);

      if (_paymentModesCount.containsKey(sale.paymentMode)) {
        _paymentModesCount[sale.paymentMode] =
            _paymentModesCount[sale.paymentMode]! + 1;
        _paymentModesAmount[sale.paymentMode] =
            _paymentModesAmount[sale.paymentMode]! +
                (sale.costLamp * sale.count + sale.costPlate * sale.plate);
      } else {
        _paymentModesCount[sale.paymentMode] = 1;
        _paymentModesAmount[sale.paymentMode] =
            (sale.costLamp * sale.count + sale.costPlate * sale.plate);
      }
    });
  }

  void discardLamps(DeepamSale sale) {
    setState(() {
      _discardedLampsCount += sale.count;
    });
  }

  void editSale() {
    refresh();
  }

  void deleteSale(DeepamSale sale) {
    setState(() {
      _totalLampsServedCount -= sale.count;
      _totalLampsServedAmount -= (sale.count * sale.costLamp);
      _totalPlatesServedCount -= sale.plate;
      _totalPlatesServedAmount -= (sale.plate * sale.costPlate);

      _paymentModesCount[sale.paymentMode] =
          _paymentModesCount[sale.paymentMode]! - 1;
      _paymentModesAmount[sale.paymentMode] =
          _paymentModesAmount[sale.paymentMode]! -
              (sale.costLamp * sale.count + sale.costPlate * sale.plate);
    });
  }

  DataRow _createRow(List<String> data, {bool bold = false}) {
    return DataRow(
      cells: data
          .map((e) => DataCell(Text(
                e,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 24.0,
                ),
              )))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: DataTable(
            columns: [
              DataColumn(label: Text('')),
              DataColumn(
                  label: Text('Count',
                      style: TextStyle(
                        fontSize: 24.0,
                      ))),
              DataColumn(
                  label: Text('Amount',
                      style: TextStyle(
                        fontSize: 24.0,
                      ))),
            ],
            rows: [
              _createRow([
                'Prepared lamps received',
                '$_preparedLampsReceivedCount',
                ''
              ]),
              _createRow([
                'Unprepared lamps received',
                '$_unpreparedLampsReceivedCount',
                ''
              ]),
              _createRow(['Plates received', '$_platesReceivedCount', '']),
              _createRow([
                'Total lamps received',
                '${_preparedLampsReceivedCount + _unpreparedLampsReceivedCount}',
                ''
              ], bold: true),
              _createRow([
                'Total lamps served',
                '$_totalLampsServedCount',
                '₹$_totalLampsServedAmount'
              ]),
              _createRow(['Discarded lamps', '$_discardedLampsCount', '']),
              _createRow([
                'Total plates served',
                '$_totalPlatesServedCount',
                '₹$_totalPlatesServedAmount'
              ]),
              _createRow([
                'Remaining lamps',
                '${_preparedLampsReceivedCount + _unpreparedLampsReceivedCount - _totalLampsServedCount}',
                ''
              ], bold: true),
              ..._paymentModesCount.keys
                  .map((mode) => _createRow([
                        '$mode transactions',
                        '${_paymentModesCount[mode]}',
                        '₹${_paymentModesAmount[mode]}'
                      ]))
                  .toList(),
              _createRow([
                'Total amount received',
                '',
                '₹${_totalLampsServedAmount + _totalPlatesServedAmount}'
              ], bold: true),

              // cash details
              // DataRow(cells: [
              //   DataCell(Text('Cash details',
              //       style: TextStyle(
              //         fontSize: 24.0,
              //       ))),
              //   DataCell(ElevatedButton(
              //     child: Text('Click'),
              //     onPressed: null,
              //   )),
              //   DataCell(Text(''))
              // ]),

              // coin details
              // DataRow(cells: [
              //   DataCell(Text('Coin details',
              //       style: TextStyle(
              //         fontSize: 24.0,
              //       ))),
              //   DataCell(ElevatedButton(
              //     child: Text('Click'),
              //     onPressed: null,
              //   )),
              //   DataCell(Text(''))
              // ]),

              // tally status
              // DataRow(cells: [
              //   DataCell(Text(
              //     'Tally status',
              //     style: TextStyle(
              //       fontSize: 24.0,
              //     ),
              //   )),
              //   DataCell(Text('No entries',
              //       style: TextStyle(color: Colors.red, fontSize: 24.0))),
              //   DataCell(Text('')),
              // ]),
            ],
          ),
        ),
      ),
    );
  }
}
