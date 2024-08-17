import 'package:flutter/material.dart';
import 'package:garuda/laddu_seva/stock_log.dart';

class LadduLog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Laddu seva log'),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Theme.of(context)
                  .primaryColorLight, // Set a lighter background color based on the theme
              child: TabBar(
                indicatorColor: Colors.white, // Set the indicator color
                labelColor: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color, // Set the label color to theme text color
                unselectedLabelColor:
                    Colors.white, // Set the unselected label color
                labelStyle: TextStyle(fontSize: 18.0),
                tabs: [
                  Tab(text: 'Stock'),
                  Tab(text: 'Distribution'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: StockLog()),
            Center(child: Text('Content for Tab 2')),
          ],
        ),
      ),
    );
  }
}
