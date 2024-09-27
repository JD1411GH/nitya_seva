import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/deepotsava/stock_add.dart';
import 'package:garuda/fb.dart';
import 'package:synchronized/synchronized.dart';

class StockPage extends StatefulWidget {
  final String stall;

  const StockPage({super.key, required this.stall});

  @override
  State<StockPage> createState() => _StockPageState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_StockPageState> templateKey = GlobalKey<_StockPageState>();

class _StockPageState extends State<StockPage> {
  final _lockInit = Lock();
  final TextEditingController _preparedLampsController =
      TextEditingController();
  final TextEditingController _unpreparedLampsController =
      TextEditingController();
  final TextEditingController _wicksController = TextEditingController();
  final TextEditingController _gheePacketsController = TextEditingController();
  final TextEditingController _oilCansController = TextEditingController();

  @override
  void dispose() {
    _preparedLampsController.dispose();
    _unpreparedLampsController.dispose();
    _wicksController.dispose();
    _gheePacketsController.dispose();
    _oilCansController.dispose();
    super.dispose();
  }

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {});
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  void _createAddStockPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StockAdd(stall: widget.stall),
      ),
    );
  }

  Widget _createStock() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'StockPage for ${widget.stall}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Prepared lamps: '),
          const Text('Unprepared lamps: '),
          const Text('Wicks: '),
          const Text('Ghee packets: '),
          const Text('Oil cans: '),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _createAddStockPage(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: null,
                ),
                IconButton(
                  icon: Icon(Icons.undo),
                  onPressed: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _futureInit(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return _createStock();
        }
      },
    );
  }
}
