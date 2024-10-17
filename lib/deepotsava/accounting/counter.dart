import 'package:flutter/cupertino.dart';
import 'package:garuda/deepotsava/fbl.dart';

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

    refresh();
  }

  void setCounter(int value) {
    setState(() {
      _scrollController.jumpToItem(value);
    });
  }

  void refresh() async {
    int counter = 0;
    DateTime beginOfYear = DateTime(DateTime.now().year, 1, 1);
    await FBL().getSales('RKC', start: beginOfYear).then((sales) {
      sales.forEach((sale) {
        counter += sale.count;
      });
    });

    await FBL().getSales('RRG', start: beginOfYear).then((sales) {
      sales.forEach((sale) {
        counter += sale.count;
      });
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
