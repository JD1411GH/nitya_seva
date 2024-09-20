import 'package:flutter/material.dart';

class ServiceSelect extends StatefulWidget {
  @override
  _ServiceSelectDialogState createState() => _ServiceSelectDialogState();
}

class _ServiceSelectDialogState extends State<ServiceSelect> {
  List<String> services = ["Service 1", "Service 2", "Service 3"];
  String? selectedService;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Service"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
            )
          ],
        ),
      ),
    );
  }
}
