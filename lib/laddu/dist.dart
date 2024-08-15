import 'package:flutter/material.dart';

class Dist extends StatefulWidget {
  @override
  _DistState createState() => _DistState();
}

class _DistState extends State<Dist> {
  final primaryColor = Colors.orange;
  bool isCollapsed = false;
  int countLaddu = 0;
  final List<String> tileData = List.generate(10, (index) => 'Tile $index');

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
                  color:
                      countLaddu == index ? primaryColor : Colors.transparent,
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
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'add notes',
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            // Add button pressed logic
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
                child: Text(
                  tile,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color),
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
    // Simulate a network call
    await Future.delayed(Duration(seconds: 2));
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
          border: Border.all(color: primaryColor),
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
                color: primaryColor, // Dark background for the title
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
