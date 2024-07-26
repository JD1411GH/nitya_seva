import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tally Notes'),
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
              const SizedBox(height: 20),
              if (validationSuccess)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Validation Success',
                        style: TextStyle(color: Colors.green)),
                  ],
                )
              else
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Validation Failed',
                        style: TextStyle(color: Colors.red)),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  int total = _calculateTotal([
                    {'value': 500, 'controller': controller500},
                    {'value': 200, 'controller': controller200},
                    {'value': 100, 'controller': controller100},
                    {'value': 50, 'controller': controller50},
                    {'value': 20, 'controller': controller20},
                    {'value': 10, 'controller': controller10},
                  ]);
                  setState(() {
                    validationSuccess = total > 0; // Example validation logic
                  });
                },
                child: const Text('Save'),
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
          Container(
            width: 50, // Adjust the width as needed to fit 3 digits
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.brown, // Set background color to brown
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
            },
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              int currentValue = int.tryParse(controller.text) ?? 0;
              setState(() {
                controller.text = (currentValue + 1).toString();
              });
            },
          ),
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
