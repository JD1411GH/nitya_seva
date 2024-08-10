import 'package:flutter/material.dart';

class AccessDenied extends StatelessWidget {
  const AccessDenied({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.block,
              size: 100, // Adjust the size as needed
              color: Colors.red, // Adjust the color as needed
            ),
            SizedBox(
                height: 20), // Add some space between the icon and the text
            Text(
              'Access Denied',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Please contact admin',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
