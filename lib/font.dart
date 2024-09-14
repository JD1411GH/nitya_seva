import 'package:flutter/material.dart';

class Font extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Font Families Demo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'This is Roboto',
                style: TextStyle(fontFamily: 'Roboto', fontSize: 24),
              ),
              Text(
                'This is Arial',
                style: TextStyle(fontFamily: 'Arial', fontSize: 24),
              ),
              Text(
                'This is Helvetica',
                style: TextStyle(fontFamily: 'Helvetica', fontSize: 24),
              ),
              Text(
                'This is Times New Roman',
                style: TextStyle(fontFamily: 'Times New Roman', fontSize: 24),
              ),
              Text(
                'This is Courier New',
                style: TextStyle(fontFamily: 'Courier New', fontSize: 24),
              ),
              Text(
                'This is Georgia',
                style: TextStyle(fontFamily: 'Georgia', fontSize: 24),
              ),
              Text(
                'This is Verdana',
                style: TextStyle(fontFamily: 'Verdana', fontSize: 24),
              ),
              Text(
                'This is Cursive',
                style: TextStyle(fontFamily: 'Cursive', fontSize: 24),
              ),
              Text(
                'This is Monospace',
                style: TextStyle(fontFamily: 'Monospace', fontSize: 24),
              ),
              Text(
                'This is Sans-serif',
                style: TextStyle(fontFamily: 'Sans-serif', fontSize: 24),
              ),
              Text(
                'This is Serif',
                style: TextStyle(fontFamily: 'Serif', fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
