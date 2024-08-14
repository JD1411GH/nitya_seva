import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/pushpanjali/datatypes.dart';
import 'package:garuda/pushpanjali/ticket_page.dart';
import 'package:intl/intl.dart';
import 'package:synchronized/synchronized.dart';

class SevaSlots extends StatefulWidget {
  const SevaSlots({super.key});

  @override
  State<SevaSlots> createState() => _SevaSlotsState();
}

final GlobalKey<_SevaSlotsState> sevaSlotsKey = GlobalKey<_SevaSlotsState>();

class _SevaSlotsState extends State<SevaSlots> {
  final _lockInit = Lock();
  List<SevaSlot> sevaSlots = [];
  final TextEditingController _slotNameController = TextEditingController();

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      sevaSlots = await FB().readSevaSlots();
      await Future.delayed(const Duration(seconds: 2));
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
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
              // Record()
              //     .registerCallbacks(RecordCallbacks(onSlotChange: refresh));
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

  Widget _getSevaSlotWidgets() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: sevaSlots.length +
                1, // Increment itemCount by 1 to include Dashboard
            itemBuilder: (context, index) {
              return Card(
                elevation: 4.0, // Adjust the elevation to control the shadow
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                // Set the background color to the primary color of the app
                child: _widgetSlots(context, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> addNewSlot() async {
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

                FB().addSevaSlot(timestampSlot, slot.toJson());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: FutureBuilder<void>(
        future: _futureInit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return sevaSlots.isEmpty
                ? const Center(
                    child: Text('No slots available'),
                  )
                : _getSevaSlotWidgets();
          }
        },
      ),
    );
  }
}
