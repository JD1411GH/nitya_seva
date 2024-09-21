import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/serve.dart';
import 'package:garuda/pushpanjali/sevaslot.dart';

class ServiceSelect extends StatefulWidget {
  @override
  _ServiceSelectDialogState createState() => _ServiceSelectDialogState();
}

class _ServiceSelectDialogState extends State<ServiceSelect> {
  List<PushpanjaliSlot> slots = [];
  List<String> services = [];
  String status = "loading";

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() async {
    slots = await FB().readPushpanjaliSlotsByDate(DateTime.now());
    List<PushpanjaliSlot> slotsYest = await FB()
        .readPushpanjaliSlotsByDate(DateTime.now().subtract(Duration(days: 1)));
    slots.addAll(slotsYest);

    setState(() {
      services = slots.map((e) => e.title).toList();
      status = services.isEmpty ? "empty" : "loaded";
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Service"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (status == "loading")
            CircularProgressIndicator()
          else if (status == "empty")
            Text(
              "No services found",
              style: TextStyle(
                fontSize: 20.0, // Increase the font size
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.red, // Color the text red
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: services.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Serve(slot: slots[index])),
                    );
                  },
                  child: Text(services[index]),
                );
              },
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
