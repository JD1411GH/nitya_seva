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
        child: ListView(
          children: [
            Text('body'),
          ],
        ),
      ),
    );
  }
}
