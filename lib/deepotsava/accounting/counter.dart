import 'package:flutter/cupertino.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/deepotsava/sales/datatypes.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

GlobalKey<_CounterState> counterKey = GlobalKey<_CounterState>();

class _CounterState extends State<Counter> {
  final List<int> _numbers = List<int>.generate(100000, (i) => i);
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController();
  }

  void setCounter(int value) {
    _scrollController.jumpToItem(value);
  }

  void addToCounter(int value) {
    int count = _scrollController.selectedItem + value;

    setState(() {
      _scrollController.animateToItem(
        count,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }

  void removeFromCounter(int value) {
    int count = _scrollController.selectedItem - value;

    setState(() {
      _scrollController.animateToItem(
        count,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> refresh({DateTime? start, DateTime? end}) async {
    int counter = 0;

    // today's sale
    List<DeepamSale> sales =
        await FBL().getSales('RKC', start: start, end: end);
    sales.forEach((sale) {
      counter += sale.count;
    });
    sales = await FBL().getSales('RRG', start: start, end: end);
    sales.forEach((sale) {
      counter += sale.count;
    });

    setCounter(counter);
  }

  @override
  Widget build(BuildContext context) {
    double height = 70;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: GestureDetector(
                // disable swiping in picker
                onVerticalDragUpdate: (_) {},
                onVerticalDragStart: (_) {},
                onVerticalDragEnd: (_) {},
                child: AbsorbPointer(
                  child: CupertinoPicker(
                    scrollController: _scrollController,
                    itemExtent: height,
                    onSelectedItemChanged: (index) {},
                    children: _numbers
                        .map((number) => Text(
                              number.toString(),
                              style: TextStyle(
                                  fontSize: height,
                                  fontFamily: 'DS-DIGI',
                                  color: CupertinoColors.white),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
