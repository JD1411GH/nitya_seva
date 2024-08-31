import 'package:flutter/material.dart';
import 'package:garuda/loading.dart';

class AccessDenied extends StatelessWidget {
  const AccessDenied({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
      ),
      body: Center(
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
              'If you have registered recently, \nplease wait for admnin approval.',
              style: TextStyle(fontSize: 18),
            ),

            // refresh and logout buttons
            SizedBox(height: 40), // Add some space before the buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // refresh
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoadingScreen()),
                    );
                  },
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
