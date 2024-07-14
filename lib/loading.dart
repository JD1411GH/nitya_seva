import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        fit: StackFit.expand, // Ensure the stack fills the screen
        children: <Widget>[
          // Background image
          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/images/ic_launcher_hires.png"), // Replace with your image path
                fit: BoxFit
                    .cover, // Cover the entire screen, cropping as necessary
              ),
            ),
          ),
          // Centered CircularProgressIndicator
          Center(
            child: SizedBox(
              width: 80, // Specify the width
              height: 80, // Specify the height
              child: CircularProgressIndicator(
                strokeWidth: 8, // Make the stroke wider
                color: Colors.white, // Set the color to white
              ),
            ),
          ),
        ],
      ),
    );
  }
}
