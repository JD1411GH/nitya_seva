import 'package:flutter/material.dart';
import 'package:garuda/const.dart';

class Serve extends StatefulWidget {
  @override
  _ServeState createState() => _ServeState();
}

class _ServeState extends State<Serve> {
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _refresh();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = List.generate(
        Const().ticketAmounts.length, (index) => TextEditingController());
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Serve laddu'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text('Seva'))),
                    TableCell(child: Center(child: Text('Tickets'))),
                    TableCell(child: Center(child: Text('Packs'))),
                  ],
                ),
                for (int i = 0; i < Const().ticketAmounts.length; i++)
                  TableRow(
                    children: [
                      TableCell(
                          child: Center(
                              child: Text(
                                  'Pushpanjali ${Const().ticketAmounts[i]}'))),
                      TableCell(
                        child: Center(
                          child: TextField(
                            controller: _controllers[i],
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(_controllers[i].text),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
