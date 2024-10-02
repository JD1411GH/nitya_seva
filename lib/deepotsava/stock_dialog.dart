import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/theme.dart';

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

                // Expand/Collapse Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Show more',
                        style: TextStyle(color: Colors.grey),
                      ),
                      IconButton(
                        icon: Icon(_isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more),
                        onPressed: () {
                          setState(() {
                            _isExpanded =
                                !_isExpanded; // Toggle expansion state
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Collapsible fields
                Visibility(
                  visible: _isExpanded, // Show only if expanded
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: TextField(
                          decoration: InputDecoration(labelText: 'Wicks'),
                          controller: _wicksController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: TextField(
                          decoration:
                              InputDecoration(labelText: 'Ghee packets'),
                          controller: _gheePacketsController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: TextField(
                          decoration: InputDecoration(labelText: 'Oil cans'),
                          controller: _oilCansController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
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

                    // Save button
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () {
                          DeepamStock stock = DeepamStock(
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
                            gheePackets: int.parse(
                              _gheePacketsController.text.isEmpty
                                  ? '0'
                                  : _gheePacketsController.text,
                            ),
                            oilCans: int.parse(
                              _oilCansController.text.isEmpty
                                  ? '0'
                                  : _oilCansController.text,
                            ),
                          );

                          widget.callbacks.add(stock);
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
  void Function(DeepamStock data) add;

  StockCallbacks({
    required this.add,
  });
}
