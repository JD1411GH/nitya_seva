import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

class Stock extends StatefulWidget {
  final String stall;

  const Stock({super.key, required this.stall});

  @override
  State<Stock> createState() => _StockState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_StockState> templateKey = GlobalKey<_StockState>();

class _StockState extends State<Stock> {
  final _lockInit = Lock();

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      await Future.delayed(const Duration(seconds: 2));
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  Widget _createStock() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Stock for ${widget.stall}',
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
                    // Add button action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Edit button action
                  },
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
