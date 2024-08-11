import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:garuda/access_denied.dart';
import 'package:garuda/login.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/menu.dart';
import 'package:garuda/pushpanjali/record.dart';
import 'package:garuda/admin/user.dart';

// Convert LoadingScreen to StatefulWidget
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // this function will either load the login screen, Pushpanjali or access denied
  Future<void> _navigateToHome() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // check if user tried to login before
    String? json = await LS().read('user_details');
    if (json != null) {
      // Yes, user tried to login before

      // Parse the JSON string
      Map<String, dynamic> userMap = jsonDecode(json);

      // Convert the parsed JSON into a UserDetails object
      UserDetails userDetails = UserDetails.fromJson(userMap);

      // Check if the user has access to the database
      String status = await FB().checkUserApprovalStatus(userDetails);
      Widget nextpage = const AccessDenied();
      if (status == "none") {
        nextpage = const AccessDenied();
      } else if (status == "pending") {
        nextpage = const AccessDenied();
      } else if (status == "approved") {
        nextpage = const Menu();
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextpage),
        );
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/Garuda.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                // color: Const().colorPrimaryVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
