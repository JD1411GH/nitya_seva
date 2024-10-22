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
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    await counterKey.currentState?.refresh();
    await detailsKey.currentState?.refresh();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDefault,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Accounting'),
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                children: [
                  DateHeader(),
                  Counter(key: counterKey),
                  Details(key: detailsKey),
                ],
              ),
            ),
            if (_isLoading)
              ModalBarrier(
                color: Colors.black.withOpacity(0.5),
                dismissible: false,
              ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
