import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nitya_seva/const.dart';
import 'package:nitya_seva/local_storage.dart';
import 'package:nitya_seva/ticket_page.dart';
import 'package:nitya_seva/record.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Widget _widgetDate(index) {
    return Expanded(
      child: Text(
        DateFormat('dd-MM-yyyy').format(
            sevaSlots[index].timestampSlot), // Extract and format the date
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _widgetTime(index) {
    return Expanded(
      child: Text(
        DateFormat('HH:mm:ss').format(
            sevaSlots[index].timestampSlot), // Extract and format the time
        textAlign: TextAlign.right, // Align the time to the right
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
      ),
    );
  }

  Widget _widgetSlots(context, index) {
    return InkWell(
      onTap: () {
        // Define your action here
        LS()
            .write('selectedSlot',
                sevaSlots[index].timestampSlot.toIso8601String())
            .then((value) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TicketTable()),
          ).then((_) {
            Record().registerCallbacks(RecordCallbacks(onSlotChange: refresh));
          });
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest, // Border color
            width: 1.0, // Border width
          ),
          borderRadius: BorderRadius.circular(4.0), // Border radius
        ),
        margin: const EdgeInsets.symmetric(
            vertical: 4.0, horizontal: 8.0), // Margin around the container
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _widgetDate(index),
                  _widgetTime(index),
                ],
              ),
              Row(children: [
                Text(sevaSlots[index].sevakartaSlot), // Display sevakarta
              ])
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(Const().appName)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: sevaSlots.length,
          itemBuilder: _widgetSlots,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSlot,
        tooltip: 'Add slot',
        child: const Icon(Icons.create_new_folder),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
