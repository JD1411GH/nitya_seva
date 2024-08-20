import 'package:flutter/material.dart';

class ButtonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.add),
          label: Text('Stock'),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.remove),
          label: Text('Serve'),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.undo),
          label: Text('Return'),
        ),
      ],
    );
  }
}
