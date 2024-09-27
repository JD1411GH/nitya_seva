import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/theme.dart';

class StockAdd extends StatefulWidget {
  final String stall;

  StockAdd({required this.stall});

  @override
  _StockAddState createState() => _StockAddState();
}

class _StockAddState extends State<StockAdd> {
  final TextEditingController _preparedLampsController =
      TextEditingController();
  final TextEditingController _unpreparedLampsController =
      TextEditingController();
  final TextEditingController _wicksController = TextEditingController();
  final TextEditingController _gheePacketsController = TextEditingController();
  final TextEditingController _oilCansController = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData selectedTheme;
    if (widget.stall == 'RRG') {
      selectedTheme = themeRRG;
    } else if (widget.stall == 'RKC') {
      selectedTheme = themeRKC;
    } else {
      selectedTheme = themeDefault;
    }

    return Theme(
        data: selectedTheme,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Add deepam stock'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(
                  16.0), // Adjust the padding value as needed
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Prepared lamps'),
                      controller: _preparedLampsController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      decoration:
                          InputDecoration(labelText: 'Unprepared lamps'),
                      controller: _unpreparedLampsController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Wicks'),
                      controller: _wicksController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Ghee packets'),
                      controller: _gheePacketsController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Oil cans'),
                      controller: _oilCansController,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // cancel button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                      ),

                      // save button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            DeepamStock stock = DeepamStock(
                              preparedLamps: int.parse(
                                  _preparedLampsController.text.isEmpty
                                      ? '0'
                                      : _preparedLampsController.text),
                              unpreparedLamps: int.parse(
                                  _unpreparedLampsController.text.isEmpty
                                      ? '0'
                                      : _unpreparedLampsController.text),
                              wicks: int.parse(_wicksController.text.isEmpty
                                  ? '0'
                                  : _wicksController.text),
                              gheePackets: int.parse(
                                  _gheePacketsController.text.isEmpty
                                      ? '0'
                                      : _gheePacketsController.text),
                              oilCans: int.parse(_oilCansController.text.isEmpty
                                  ? '0'
                                  : _oilCansController.text),
                            );

                            await FBL().addStock(widget.stall, stock);

                            Navigator.of(context).pop();
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
