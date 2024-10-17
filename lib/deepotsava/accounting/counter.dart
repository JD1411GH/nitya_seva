import 'package:flutter/cupertino.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

GlobalKey<_CounterState> counterKey = GlobalKey<_CounterState>();

class _CounterState extends State<Counter> {
  final List<int> _numbers = List<int>.generate(100000, (i) => i);

  @override
  Widget build(BuildContext context) {
    double height = 70;

    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: CupertinoPicker(
                itemExtent: height,
                onSelectedItemChanged: null,
                children: _numbers
                    .map((number) => Text(
                          number.toString(),
                          style: TextStyle(fontSize: height * 0.8),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
