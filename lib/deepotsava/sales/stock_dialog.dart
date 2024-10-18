import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/sales/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/theme.dart';
import 'package:garuda/utils.dart';

class StockAddDialog extends StatefulWidget {
  final String stall;
  final StockCallbacks callbacks;

  StockAddDialog({required this.stall, required this.callbacks});

  @override
  _StockAddDialogState createState() => _StockAddDialogState();
}

class _StockAddDialogState extends State<StockAddDialog> {
  final TextEditingController _preparedLampsController =
      TextEditingController();
  final TextEditingController _unpreparedLampsController =
      TextEditingController();
  final TextEditingController _platesController = TextEditingController();
  final TextEditingController _wicksController = TextEditingController();
  final TextEditingController _gheePacketsController = TextEditingController();
  final TextEditingController _oilCansController = TextEditingController();

  bool _isExpanded = false;

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
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // title
                Text(
                  'Add Deepam Stock',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                // prepared lamps
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Prepared lamps'),
                    controller: _preparedLampsController,
                    keyboardType: TextInputType.number,
                  ),
                ),

                // unprepared lamps
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Unprepared lamps'),
                    controller: _unpreparedLampsController,
                    keyboardType: TextInputType.number,
                  ),
                ),

                // plates
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Plates'),
                    controller: _platesController,
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Collapsible fields
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Wicks'),
                        controller: _wicksController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                // Button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),

                    // Add button
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () async {
                          String username = await Utils().getUserName();
                          DeepamStock stock = DeepamStock(
                            stall: widget.stall,
                            timestamp: DateTime.now(),
                            user: username,
                            preparedLamps: int.parse(
                              _preparedLampsController.text.isEmpty
                                  ? '0'
                                  : _preparedLampsController.text,
                            ),
                            unpreparedLamps: int.parse(
                              _unpreparedLampsController.text.isEmpty
                                  ? '0'
                                  : _unpreparedLampsController.text,
                            ),
                            plates: int.parse(
                              _platesController.text.isEmpty
                                  ? '0'
                                  : _platesController.text,
                            ),
                            wicks: int.parse(
                              _wicksController.text.isEmpty
                                  ? '0'
                                  : _wicksController.text,
                            ),
                            gheePackets: 0,
                            oilCans: 0,
                          );

                          widget.callbacks.add(stock, localUpdate: true);
                          FBL().addStock(widget.stall, stock);

                          Navigator.of(context).pop();
                        },
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// To show the dialog in your app:
void showStockAddDialog(
    BuildContext context, String stall, StockCallbacks callbacks) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StockAddDialog(stall: stall, callbacks: callbacks);
    },
  );
}

class StockCallbacks {
  void Function(DeepamStock data, {bool localUpdate}) add;

  StockCallbacks({
    required this.add,
  });
}
