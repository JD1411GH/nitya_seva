import 'package:flutter/material.dart';
import 'package:nitya_seva/local_storage.dart';
import 'package:nitya_seva/login.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.exit_to_app),
        onPressed: () {
          LS().delete('username');
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        });
  }
}
