import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/toaster.dart';

class Stock extends StatefulWidget {
  @override
  _StockState createState() => _StockState();
}

class _StockState extends State<Stock> {
  final primaryColor = Colors.green;
  bool isCollapsed = false;
  int total_procured = 0;
  int total_distributed = 0;
  int procured_today = 0;
  int distributed_today = 0;

  Future<void> _futureInit() async {
    total_procured = await FB().readLadduStock();
    // total_distributed = await FB().getTotalDistributed();
    // procured_today = await FB().getProcuredToday();
    // distributed_today = await FB().getDistributedToday();
  }

  @override
  void initState() {
    super.initState();
    _futureInit();
  }

  void _addStock(BuildContext context) {
    int procured = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Packs procured'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  procured = int.parse(value);
                },
              ),
            ],
          ),
          actions: [
            // cancel button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),

            // add button
            ElevatedButton(
              onPressed: () async {
                bool status = await FB().addLadduStock(procured);
                if (!status) {
                  Toaster().error("Add failed");
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureInit(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Padding(
            padding: const EdgeInsets.only(
                top: 8.0,
                left: 8.0,
                right: 8.0), // Reduced padding to the top, left, and right
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor),
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Take only the space needed by children
                children: [
                  // title bar
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isCollapsed =
                            !isCollapsed; // Toggle the collapsed state
                      });
                    },
                    child: Container(
                      color: primaryColor, // Dark background for the title
                      width:
                          double.infinity, // Fill the entire horizontal space
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Stock Management',
                        style: TextStyle(
                          color: Colors.white, // Set the text color to white
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ),
                  ),

                  if (!isCollapsed)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // total procured
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Total procured = $total_procured packs',
                            ),
                          ),

                          // total distributed
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Total distributed = $total_distributed packs',
                            ),
                          ),

                          // remaining
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Total remaining = ${total_procured - total_distributed} packs',
                            ),
                          ),

                          Divider(),

                          // procured today
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Procured today = $procured_today packs',
                            ),
                          ),

                          // distributed today
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Distributed today = $distributed_today packs',
                            ),
                          ),

                          Divider(),

                          // add button and logs button in the same row
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // add button
                                ElevatedButton(
                                  onPressed: () {
                                    _addStock(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        primaryColor, // Set the background color to light green
                                  ),
                                  child: Text('Add'),
                                ),

                                // logs button
                                SizedBox(
                                  width:
                                      10, // Add some spacing between the buttons
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Logs button logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        primaryColor, // Set the background color to light green
                                  ),
                                  child: Text('Logs'),
                                ),

                                // validate button
                                SizedBox(
                                  width:
                                      10, // Add some spacing between the buttons
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        primaryColor, // Set the background color to light green
                                  ),
                                  child: Text('Validate'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
