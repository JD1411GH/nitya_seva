import 'package:flutter/material.dart';

class LadduMain extends StatefulWidget {
  @override
  _LadduSevaState createState() => _LadduSevaState();
}

class _LadduSevaState extends State<LadduMain> {
  @override
  initState() {
    super.initState();

    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laddu Seva'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,

        // here a ListView is used to allow the content to be scrollable and refreshable.
        // If you use ListView.builder inside this, then the ListView here can be removed.
        // Often putting widget inside ListView causes app to crash. One possible way
        // to solve this is to use a SizedBox inside the child widget.
        // e.g. Card(
        //   child: SizedBox(
        //     height: 300.0, // Set a fixed height for the PageView
        //     child: PageView(
        //       children: <Widget>[
        //         Container(
        //           color: Colors.red,
        //           child: Center(child: Text('Page 1')),
        //         ),
        //       ],
        //     ),
        //   ),
        // )
        child: ListView(
          children: [
            Text('body'),
          ],
        ),
      ),
    );
  }
}
