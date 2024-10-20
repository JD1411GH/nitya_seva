import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/deepotsava/sales/datatypes.dart';

class LogDialog extends StatefulWidget {
  final DeepamSale sale;
  final LogDialogCallbacks callbacks;
  const LogDialog({super.key, required this.sale, required this.callbacks});

  @override
  _LogDialogState createState() => _LogDialogState();
}

class _LogDialogState extends State<LogDialog> {
  late String selectedPaymentMode;

  // controllers to get values from the dialog
  TextEditingController _lampcountController = TextEditingController();
  TextEditingController _platecountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedPaymentMode = widget.sale.paymentMode;
  }

  void _deleteSale(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this sale?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // delete the sale object
                widget.callbacks.delete(widget.sale, localUpdate: true);

                // close the confirmation dialog
                Navigator.of(context).pop();

                // close the main dialog
                Navigator.of(context).pop();
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> paymentModes = Const().paymentModes.keys.toList();

    return AlertDialog(
      title: Text("Edit deepam sale"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // lamps served
          Row(
            children: [
              (widget.sale.paymentMode == 'Discard')
                  ? Text("Lamps discarded: ")
                  : Text("Lamps served: "),
              Spacer(),
              Expanded(
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _lampcountController
                    ..text = "${widget.sale.count}",
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),

          // plates served
          if (widget.sale.paymentMode != 'Discard')
            Row(
              children: [
                Text("Plates served: "),
                Spacer(),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: _platecountController
                      ..text = "${widget.sale.plate}",
                    keyboardType: TextInputType.number,
                    readOnly: true, // Make the text field uneditable
                  ),
                )
              ],
            ),

          // payment mode
          if (widget.sale.paymentMode != 'Discard')
            Row(
              children: [
                Text("Payment mode: "),
                SizedBox(width: 30),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedPaymentMode,
                    onChanged: (String? newValue) {
                      if (!mounted) return;
                      setState(() {
                        selectedPaymentMode = newValue!;
                      });
                    },
                    items: paymentModes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            )
        ],
      ),
      actions: [
        // delete button
        if (widget.sale.paymentMode != 'Discard')
          TextButton(
            onPressed: () {
              _deleteSale(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),

        // cancel button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),

        // update button
        TextButton(
          onPressed: () async {
            // update the sale object
            DeepamSale updatedSale = widget.sale.copyWith(
              count: int.parse(_lampcountController.text),
              plate: (_platecountController.text == "true" ? true : false),
              paymentMode: selectedPaymentMode,
            );

            // call the edit callback
            widget.callbacks.edit(updatedSale, localUpdate: true);

            // close the dialog
            Navigator.of(context).pop();
          },
          child: Text("Update"),
        ),
      ],
    );
  }
}

class LogDialogCallbacks {
  void Function(DeepamSale data, {bool localUpdate}) edit;
  void Function(DeepamSale data, {bool localUpdate}) delete;

  LogDialogCallbacks({
    required this.edit,
    required this.delete,
  });
}
