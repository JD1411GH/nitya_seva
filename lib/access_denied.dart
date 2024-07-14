import 'package:flutter/material.dart';
import 'package:nitya_seva/login.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/logout.dart';

class AccessDenied extends StatelessWidget {
  const AccessDenied({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: const <Widget>[
          LogoutButton(),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
