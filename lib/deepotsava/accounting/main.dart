import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/accounting/counter.dart';
import 'package:garuda/deepotsava/accounting/details.dart';
import 'package:garuda/deepotsava/sales/datatypes.dart';
import 'package:garuda/deepotsava/date_header.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/theme.dart';

class Accounting extends StatefulWidget {
  @override
  _AccountingState createState() => _AccountingState();
}

class _AccountingState extends State<Accounting> {
  @override
  initState() {
    super.initState();

    // listeners for RKC sales
    // FBL().listenForChange(
    //     "deepotsava/RKC/sales",
    //     FBLCallbacks(
    //         // add
    //         add: (data) async {
    //       counterKey.currentState?.addToCounter(data['count']);
    //     },

    //         // edit
    //         edit: () async {
    //       counterKey.currentState?.refresh();
    //       pieKey.currentState?.refresh();
    //     },

    //         // delete
    //         delete: (data) async {
    //       counterKey.currentState?.removeFromCounter(data['count']);

    //       Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
    //       DeepamSale sale = DeepamSale.fromJson(map);
    //       pieKey.currentState?.removeSale(sale);
    //     }));

    // listeners for RRG sales
    // FBL().listenForChange(
    //     "deepotsava/RRG/sales",
    //     FBLCallbacks(add: (data) async {
    //       counterKey.currentState?.addToCounter(data['count']);

    //       Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
    //       DeepamSale sale = DeepamSale.fromJson(map);
    //       pieKey.currentState?.addSale(sale);
    //     }, edit: () async {
    //       counterKey.currentState?.refresh();
    //       pieKey.currentState?.refresh();
    //     }, delete: (data) async {
    //       counterKey.currentState?.removeFromCounter(data['count']);

    //       Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
    //       DeepamSale sale = DeepamSale.fromJson(map);
    //       pieKey.currentState?.removeSale(sale);
    //     }));
  }

  Future<void> refresh() async {
    await counterKey.currentState?.refresh();
    await detailsKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDefault,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Accounting'),
        ),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            children: [
              DateHeader(),
              Counter(key: counterKey),
              Details(key: detailsKey),
            ],
          ),
        ),
      ),
    );
  }
}
