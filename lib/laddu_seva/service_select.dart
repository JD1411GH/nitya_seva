import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/pushpanjali/sevaslot.dart';

class ServiceSelect extends StatefulWidget {
  @override
  _ServiceSelectDialogState createState() => _ServiceSelectDialogState();
}

class _ServiceSelectDialogState extends State<ServiceSelect> {
  List<String> services = [];
  String? selectedService;
  String status = "loading";

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() async {
    List<SevaSlot> slots =
        await FB().readPushpanjaliSlotsByDate(DateTime.now());

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
              "No services today",
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
                return RadioListTile<String>(
                  title: Text(services[index]),
                  value: services[index],
                  groupValue: selectedService,
                  onChanged: (value) {
                    setState(() {
                      selectedService = value;
                    });
                  },
                );
              },
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (status == "loaded")
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, selectedService);
                  },
                  child: Text("Select"),
                ),
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
