import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/deepotsava/datatypes.dart';

class LogDialog extends StatefulWidget {
  final DeepamSale sale;
  const LogDialog({super.key, required this.sale});

  @override
  _LogDialogState createState() => _LogDialogState();
}

class _LogDialogState extends State<LogDialog> {
  late String selectedPaymentMode;

  @override
  void initState() {
    super.initState();
    selectedPaymentMode = widget.sale.paymentMode;
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
              Text("Lamps served: "),
              Spacer(),
              Expanded(
                child: TextField(
                  textAlign: TextAlign.center,
                  controller:
                      TextEditingController(text: "${widget.sale.count}"),
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),

          // plates served
          Row(
            children: [
              Text("Plates served: "),
              Spacer(),
              Expanded(
                child: TextField(
                  textAlign: TextAlign.center,
                  controller:
                      TextEditingController(text: "${widget.sale.plate}"),
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),

          // payment mode
          Row(
            children: [
              Text("Payment mode: "),
              SizedBox(width: 30),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedPaymentMode,
                  onChanged: (String? newValue) {
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
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }
}
