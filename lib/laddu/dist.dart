import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garuda/admin/user.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu/laddu_datatypes.dart';
import 'package:garuda/laddu/stock.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/toaster.dart';
import 'package:intl/intl.dart';

class Dist extends StatefulWidget {
  @override
  _DistState createState() => _DistState();
}

class _DistState extends State<Dist> {
  final localColor = Colors.orange;
  bool isCollapsed = false;
  int countLaddu = 0;
  List<LadduDist> tileData = [];
  final TextEditingController _controllerNote = TextEditingController();

  @override
  void dispose() {
    _controllerNote.dispose();
    super.dispose();
  }

  Widget _getCountPicker() {
    return Container(
      height: 50.0, // Adjust the height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 100,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                countLaddu = index;
              });
            },
            child: Container(
              width: 50.0, // Adjust the width as needed
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: countLaddu == index ? localColor : Colors.transparent,
                  width: 2.0,
                ),
              ),
              child: Text(
                index.toString(),
                style: TextStyle(fontSize: 24),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getAddButton() {
    return Row(
      children: [
        // text field for note
        Expanded(
          child: TextField(
            controller: _controllerNote,
            decoration: InputDecoration(
              hintText: 'add notes',
            ),
          ),
        ),

        // add button
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () async {
            _controllerNote.text = '';

            var u = await LS().read('user_details');
            if (u != null) {
              var uu = jsonDecode(u);
              UserDetails user = UserDetails.fromJson(uu);

              LadduDist dist = LadduDist(
                timestamp: DateTime.now(),
                user: user.name!,
                count: countLaddu,
                note: _controllerNote.text,
              );

              bool status = await FB().addLadduDist(dist);
              if (status) {
                await StockStateKey.currentState!.refresh();
                Toaster().info("Add success");
              } else {
                Toaster().error("Add failed");
              }
            } else {
              Toaster().error("Error");
            }
          },
        ),

        // log button
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () {
            // Log button pressed logic
          },
        ),
      ],
    );
  }

  Widget _getDistList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: // Define a list of tile data

          // Use the list to generate the tiles
          Row(
        children: tileData.map((tile) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16.0), // Adjust the radius as needed
            ),
            margin: EdgeInsets.all(8.0),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0), // Increase padding as needed
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          "Time: ${DateFormat('HH:mm').format(tile.timestamp)}",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        Text(
                          "Count: ${tile.count}",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ],
                    ),
                    if (tile.note.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0), // Adjust the value as needed
                        child: Icon(
                          Icons.note,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
          ;
        }).toList(),
      ),
    );
  }

  Future<void> _futureInit() async {
    tileData = await FB().readLadduDists();
    tileData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 8.0,
          left: 8.0,
          right: 8.0), // Reduced padding to the top, left, and right
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(color: localColor),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Take only the space needed by children
          children: [
            // header
            GestureDetector(
              onTap: () {
                setState(() {
                  isCollapsed = !isCollapsed; // Toggle the collapsed state
                });
              },
              child: Container(
                color: localColor, // Dark background for the title
                width: double.infinity, // Fill the entire horizontal space
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Distribution',
                  style: TextStyle(
                    color: Colors.white, // Set the text color to white
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold, // Make the text bold
                  ),
                ),
              ),
            ),

            // body
            if (!isCollapsed)
              FutureBuilder(
                future:
                    _futureInit(), // Replace with your actual future function
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          _getCountPicker(),
                          _getAddButton(),
                          Divider(),
                          _getDistList(),
                        ],
                      ),
                    );
                  }
                },
              )
          ],
        ),
      ),
    );
  }
}
