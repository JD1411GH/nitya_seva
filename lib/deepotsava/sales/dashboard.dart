import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/sales/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';

class Dashboard extends StatefulWidget {
  final String stall;

  const Dashboard({super.key, required this.stall});

  @override
  State<Dashboard> createState() => _DashboardState();
}

// hint: dashboardKey.currentState!.refresh();
final GlobalKey<_DashboardState> dashboardKey = GlobalKey<_DashboardState>();

class _DashboardState extends State<Dashboard> {
  int _lampsIssued = 0;

  DateTime _localUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    refresh();

    // subscribe for updates
    FBL().listenForChange(
        "deepotsava/${widget.stall}/sales",
        FBLCallbacks(
            // add
            add: (data) async {
          if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) return;

          Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
          DeepamSale sale = DeepamSale.fromJson(map);
          addLampsServed(sale, localUpdate: false);
        }, delete: (data) async {
          if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) return;

          Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
          DeepamSale sale = DeepamSale.fromJson(map);
          deleteLampsServed(sale, localUpdate: false);
        },

            // edit
            edit: () async {
          if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) return;

          refresh();
        }));
  }

  Future<void> refresh() async {
    List<DeepamSale> sales = await FBL().getSales(widget.stall);

    if (!mounted) return;
    setState(() {
      _lampsIssued = 0;
      sales.forEach((sale) {
        if (sale.count > 0) {
          _lampsIssued += sale.count;
        }
      });
    });
  }

  void addLampsServed(DeepamSale sale, {bool localUpdate = true}) {
    if (!mounted) return;
    setState(() {
      _lampsIssued += sale.count;
    });

    if (localUpdate) {
      _localUpdateTime = DateTime.now();
    }
  }

  void deleteLampsServed(DeepamSale sale, {bool localUpdate = true}) {
    if (!mounted) return;
    setState(() {
      _lampsIssued -= sale.count;
    });

    if (localUpdate) {
      _localUpdateTime = DateTime.now();
    }
  }

  Widget _createLampCount() {
    _localUpdateTime = DateTime.now();

    return CircleAvatar(
      child: Text(
        '$_lampsIssued',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _createLampCount();
  }
}
