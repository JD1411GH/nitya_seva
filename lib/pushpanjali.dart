import 'package:flutter/material.dart';
import 'package:garuda/dashboard.dart';
import 'package:intl/intl.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/ticket_page.dart';
import 'package:garuda/record.dart';
import 'package:garuda/datatypes.dart';
import 'package:garuda/dashboard.dart';

class Pushpanjali extends StatefulWidget {
  const Pushpanjali({super.key});

  @override
  State<Pushpanjali> createState() => _HomePageState();
}

class _HomePageState extends State<Pushpanjali> {
  List<SevaSlot> sevaSlots = Record().sevaSlots;
  final TextEditingController _slotNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Record().registerCallbacks(RecordCallbacks(onSlotChange: refresh));
  }

  Future<void> _addNewSlot() async {
    String? username = await LS().read('username');

    // pre-fill the slot name with the time of day
    DateTime timestampSlot = DateTime.now();
    String dayName = DateFormat('EEE').format(timestampSlot);
    int hour = timestampSlot.hour;
    String timeOfDay;
    if (hour >= 5 && hour < 14) {
      timeOfDay = "Morning";
    } else if (hour >= 15 && hour < 21) {
      timeOfDay = "Evening";
    } else {
      timeOfDay = "Other";
    }
    _slotNameController.text = '$dayName $timeOfDay';

    showDialog<void>(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Slot Name'),
          content: TextField(
            controller: _slotNameController,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                SevaSlot slot = SevaSlot(
                    timestampSlot: timestampSlot,
                    title: _slotNameController.text,
                    sevakartaSlot: username!);
                Record().addSevaSlot(timestampSlot, slot);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void refresh() {
    setState(() {
      sevaSlots = Record().sevaSlots;
    });
  }

  Future<void> _refreshFull() async {
    Record().refreshSevaSlots();
    refresh();
  }

  Widget _widgetDate(index) {
    return Expanded(
      child: Text(
        DateFormat('dd-MM-yyyy').format(
            sevaSlots[index].timestampSlot), // Extract and format the date
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context)
              .primaryColor, // Set text color to primary theme color
        ),
      ),
    );
  }

  Widget _widgetTime(index) {
    return Expanded(
      child: Text(
        DateFormat('HH:mm:ss').format(
            sevaSlots[index].timestampSlot), // Extract and format the time
        textAlign: TextAlign.right, // Align the time to the right
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _widgetSlots(context, index) {
    return InkWell(
        // Define your action here for onTap
        onTap: () {
          LS()
              .write('selectedSlot',
                  sevaSlots[index].timestampSlot.toIso8601String())
              .then((value) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TicketTable()),
            ).then((_) {
              Record()
                  .registerCallbacks(RecordCallbacks(onSlotChange: refresh));
            });
          });
        },

        // contents of the slot tile
        child: Container(
          margin: const EdgeInsets.symmetric(
              vertical: 4.0, horizontal: 8.0), // Margin around the container
          child: ListTile(
            // title
            title: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Space between title and icon
              children: <Widget>[
                Expanded(
                  child: Text(
                    sevaSlots[index].title,
                    style: TextStyle(
                      color: Theme.of(context)
                          .primaryColor, // Use the primary color
                      fontWeight: FontWeight.bold, // Bold font
                      fontSize: 24.0, // Increase the font size
                    ),
                  ),
                ),

                // Icon for time of day
                Icon(
                  sevaSlots[index].timestampSlot.hour < 15
                      ? Icons.wb_sunny
                      : Icons
                          .nights_stay, // Use sun icon for morning and moon icon for evening
                  color: Theme.of(context)
                      .primaryColor, // Set icon color to primary theme color
                ),
              ],
            ),

            // subtitle
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _widgetDate(index),
                    _widgetTime(index),
                  ],
                ),
                const SizedBox(height: 8.0), // Space between rows
                Text(
                  sevaSlots[index].sevakartaSlot,
                ),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pushpanjali Seva",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: _refreshFull,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: sevaSlots.length +
                      1, // Increment itemCount by 1 to include Dashboard
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Return Dashboard widget as the first item
                      return const Dashboard();
                    }
                    // Adjust index for sevaSlots
                    final adjustedIndex = index - 1;
                    return Card(
                      elevation:
                          4.0, // Adjust the elevation to control the shadow
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      // Set the background color to the primary color of the app
                      child: _widgetSlots(context, adjustedIndex),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSlot,
        tooltip: 'Add slot',
        backgroundColor: Theme.of(context)
            .primaryColor, // Set background color to match AppBar
        child: const Icon(
          Icons.create_new_folder,
          color: Colors.white,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}