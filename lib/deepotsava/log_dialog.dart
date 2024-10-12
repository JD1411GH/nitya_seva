import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';

class LogDialog extends StatelessWidget {
  final DeepamSale sale;
  const LogDialog({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
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
                  controller: TextEditingController(text: "${sale.count}"),
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
                  controller: TextEditingController(text: "${sale.plate}"),
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),

          // payment mode
          Row(
            children: [
              Text("Payment mode: "),
              SizedBox(width: 20),
              Expanded(
                child: DropdownButton<String>(
                  value: sale.paymentMode,
                  onChanged: (String? newValue) {
                    // Handle the change in payment mode here
                  },
                  items: <String>['Cash', 'Card', 'Online']
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
