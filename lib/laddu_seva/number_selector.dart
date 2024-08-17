import 'package:flutter/material.dart';

class NumberSelector extends StatefulWidget {
  NumberSelector({Key? key}) : super(key: key);

  @override
  _NumberSelectorState createState() => _NumberSelectorState();
}

final GlobalKey<_NumberSelectorState> numberSelectorKey =
    GlobalKey<_NumberSelectorState>();

class _NumberSelectorState extends State<NumberSelector> {
  int _selectedNumber = -1;

  int get selectedNumber => _selectedNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (context, index) {
          int number = index + 1;
          bool isSelected = number == _selectedNumber;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedNumber = number;
              });
            },
            child: Container(
              width: 50,
              alignment: Alignment.center,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Text(
                '$number',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 20,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
