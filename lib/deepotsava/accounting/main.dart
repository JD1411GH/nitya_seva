import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/accounting/counter.dart';
import 'package:garuda/deepotsava/accounting/details.dart';
import 'package:garuda/deepotsava/date_header.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/theme.dart';
import 'package:flutter/scheduler.dart';

class Accounting extends StatefulWidget {
  @override
  _AccountingState createState() => _AccountingState();
}

class _AccountingState extends State<Accounting> {
  bool _isLoading = true;
  late DateTime _start;
  late DateTime _end;

  @override
  initState() {
    super.initState();

    DateTime now = DateTime.now();
    _start = DateTime(now.year, now.month, now.day);
    _end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      refresh();
    });

    // listeners
    for (String service in ["sales", "stocks", "discards"]) {
      for (String stall in ["RKC", "RRG"]) {
        FBL().listenForChange(
            "deepotsava/$stall/$service",
            FBLCallbacks(
                // add
                add: (data) async {
              if (service == "sales")
                counterKey.currentState!.addToCounter(data['count']);

              await detailsKey.currentState!.refresh(start: _start, end: _end);

              if (mounted) setState(() {});
            },

                // edit
                edit: () async {
              await counterKey.currentState!.refresh(start: _start, end: _end);
              await detailsKey.currentState!.refresh(start: _start, end: _end);

              if (mounted) setState(() {});
            },

                // delete
                delete: (data) async {
              if (service == "sales")
                counterKey.currentState!.removeFromCounter(data['count']);

              await detailsKey.currentState!.refresh(start: _start, end: _end);
              setState(() {});
            }));
      }
    }
  }

  Future<void> refresh() async {
    await counterKey.currentState!.refresh(start: _start, end: _end);
    await detailsKey.currentState!.refresh(start: _start, end: _end);

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
