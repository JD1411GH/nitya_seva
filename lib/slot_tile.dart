import 'package:flutter/material.dart';

class SlotTile extends StatelessWidget {
  final String buttonText; // Add a final String variable to hold the text input
  const SlotTile({super.key, required this.buttonText}); // Modify the constructor to require the text input

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Your button action here
        },
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft, // Aligns the button text to the left
        ),
        child: Text(buttonText), // Use the buttonText variable here
      ),
    );
  }
}