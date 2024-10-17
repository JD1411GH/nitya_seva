import 'package:flutter/cupertino.dart';

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

  void setPickerValue(int value) {
    _scrollController.jumpToItem(value);
  }

  @override
  Widget build(BuildContext context) {
    double height = 70;

    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: GestureDetector(
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
                                  fontSize: height, fontFamily: 'DS-DIGI'),
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
