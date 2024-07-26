import 'package:flutter/material.dart';
import 'package:nitya_seva/const.dart';
import 'package:nitya_seva/fb.dart';
import 'package:nitya_seva/local_storage.dart';
import 'package:nitya_seva/record.dart';
import 'package:nitya_seva/toaster.dart';

class TallyNotesPage extends StatefulWidget {
  const TallyNotesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TallyNotesPageState createState() => _TallyNotesPageState();
}

class _TallyNotesPageState extends State<TallyNotesPage> {
  final TextEditingController controller500 = TextEditingController(text: '0');
  final TextEditingController controller200 = TextEditingController(text: '0');
  final TextEditingController controller100 = TextEditingController(text: '0');
  final TextEditingController controller50 = TextEditingController(text: '0');
  final TextEditingController controller20 = TextEditingController(text: '0');
  final TextEditingController controller10 = TextEditingController(text: '0');

  bool validationSuccess = false;
  int? sumCash;
  DateTime? timestampSlot;

  @override
  void initState() {
    super.initState();

    LS().read("selectedSlot").then((value) {
      sumCash = 0;
      if (value != null) {
        timestampSlot = DateTime.parse(value);
        List<SevaTicket>? sevatickets = Record().sevaTickets[timestampSlot];
        if (sevatickets != null) {
          for (SevaTicket sevaticket in sevatickets) {
            if (sevaticket.mode == 'Cash') {
              sumCash = sumCash! + sevaticket.amount;
            }
          }
        }
      }
    });
  }

  Widget _widgetTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0, // Increase the font size
          ),
        ),
        Row(
          children: [
            // sum of the entries
            Text(
              _calculateTotal([
                {'value': 500, 'controller': controller500},
                {'value': 200, 'controller': controller200},
                {'value': 100, 'controller': controller100},
                {'value': 50, 'controller': controller50},
                {'value': 20, 'controller': controller20},
                {'value': 10, 'controller': controller10},
              ]).toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0, // Increase the font size
              ),
            ),

            const SizedBox(
                width:
                    8), // Add some space between the icon and the total amount

            Container(
              // validation success icon
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: validationSuccess
                    ? Const().colorSuccess
                    : Const().colorError,
              ),
              padding:
                  const EdgeInsets.all(1.0), // Adjust the padding as needed
              child: Icon(
                validationSuccess ? Icons.check : Icons.close,
                color:
                    Colors.white, // Icon color to contrast with the background
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _validateTotal() {
    setState(() {
      if (sumCash != null) {
        var total = _calculateTotal([
          {'value': 500, 'controller': controller500},
          {'value': 200, 'controller': controller200},
          {'value': 100, 'controller': controller100},
          {'value': 50, 'controller': controller50},
          {'value': 20, 'controller': controller20},
          {'value': 10, 'controller': controller10},
        ]);
        validationSuccess = (total == sumCash);
      } else {
        validationSuccess = false;
      }
    });
  }

  void _dialogSave(BuildContext context) {
    // decide the content of the dialog box
    var total = _calculateTotal([
      {'value': 500, 'controller': controller500},
      {'value': 200, 'controller': controller200},
      {'value': 100, 'controller': controller100},
      {'value': 50, 'controller': controller50},
      {'value': 20, 'controller': controller20},
      {'value': 10, 'controller': controller10},
    ]);
    var diff = total - sumCash!;
    var msg = Text(
      'Cash is matching.\nDo you want to save?',
      style: TextStyle(color: Const().colorPrimary),
    );
    if (diff > 0) {
      msg = Text(
        'Cash is more by $diff.\nDo you want to save?',
        style: TextStyle(color: Const().colorError),
      );
    } else if (diff < 0) {
      msg = Text(
        'Cash is less by ${diff.abs()}.\nDo you want to save?',
        style: TextStyle(color: Const().colorError),
      );
    }

    // show the dialog box
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: msg,
          actions: <Widget>[
            // No button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),

            // Yes button
            TextButton(
              onPressed: () {
                if (timestampSlot != null) {
                  Map<String, int> json = {
                    '500': int.tryParse(controller500.text) ?? 0,
                    '200': int.tryParse(controller200.text) ?? 0,
                    '100': int.tryParse(controller100.text) ?? 0,
                    '50': int.tryParse(controller50.text) ?? 0,
                    '20': int.tryParse(controller20.text) ?? 0,
                    '10': int.tryParse(controller10.text) ?? 0,
                  };

                  FB().addUpdateTallyCash(timestampSlot!, json);
                } else {
                  Toaster().error('Unable to save');
                }

                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to summary page
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tally Cash'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              _buildDenominationField('500', controller500),
              _buildDenominationField('200', controller200),
              _buildDenominationField('100', controller100),
              _buildDenominationField('50', controller50),
              _buildDenominationField('20', controller20),
              _buildDenominationField('10', controller10),

              // the sum total
              const Divider(),
              _widgetTotal(),
              const Divider(),

              // save button
              ElevatedButton(
                onPressed: () {
                  _dialogSave(context);
                },
                child: const Text('Verify & Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDenominationField(
      String denomination, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          // denomination label
          Container(
            width: 50, // Adjust the width as needed to fit 3 digits
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Const().colorPrimary, // Set background color to brown
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Text(
                denomination,
                style: const TextStyle(
                  color: Colors.white, // Set font color to white
                  fontWeight: FontWeight.bold, // Make the font bold
                ),
              ),
            ),
          ),

          // subtract button
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              int currentValue = int.tryParse(controller.text) ?? 0;
              if (currentValue > 0) {
                setState(() {
                  controller.text = (currentValue - 1).toString();
                });
              }
              _validateTotal();
            },
          ),

          // number of notes
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _validateTotal();
                });
              },
            ),
          ),

          // add button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              int currentValue = int.tryParse(controller.text) ?? 0;
              setState(() {
                controller.text = (currentValue + 1).toString();
              });
              _validateTotal();
            },
          ),

          // total amount
          const SizedBox(width: 8),
          Container(
            width: 60, // Adjust the width as needed to fit 5 digits
            alignment: Alignment.center, // Center the text within the container
            child: Text(
              '${(int.tryParse(controller.text) ?? 0) * int.parse(denomination)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold, // Make the font bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotal(List<Map<String, dynamic>> denominations) {
    int total = 0;
    for (var denomination in denominations) {
      int value = denomination['value'];
      TextEditingController controller = denomination['controller'];
      int count = int.tryParse(controller.text) ?? 0;
      total += value * count;
    }
    return total;
  }
}
