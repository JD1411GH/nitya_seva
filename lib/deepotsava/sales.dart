import 'package:flutter/material.dart';
import 'package:garuda/theme.dart';

class Sales extends StatefulWidget {
  final String stall;

  Sales({required this.stall});

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  @override
  initState() {
    super.initState();

    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  Widget _createCardPage() {
    return Card(
      child: SizedBox(
        height: 200.0,
        child: PageView(
          children: <Widget>[
            Container(
              color: Colors.red,
              child: Center(child: Text('Page 1')),
            ),
            Container(
              color: Colors.green,
              child: Center(child: Text('Page 2')),
            ),
            Container(
              color: Colors.blue,
              child: Center(child: Text('Page 3')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Select theme based on the value of stall
    ThemeData selectedTheme;
    if (widget.stall == 'RRG') {
      selectedTheme = themeRRG;
    } else if (widget.stall == 'RKC') {
      selectedTheme = themeRKC;
    } else {
      selectedTheme = themeDefault;
    }

    return Theme(
      data: selectedTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.stall} Deepam Sales'),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,

          // here a ListView is used to allow the content to be scrollable and refreshable.
          // If you use ListView.builder inside this, then the ListView here can be removed.
          child: ListView(
            children: [
              _createCardPage(),
            ],
          ),
        ),
      ),
    );
  }
}
