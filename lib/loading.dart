import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nitya_seva/access_denied.dart';
import 'package:nitya_seva/login.dart';
import 'package:nitya_seva/home.dart';
import 'package:nitya_seva/local_storage.dart';
import 'package:nitya_seva/fb.dart';
import 'package:nitya_seva/record.dart';

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

  // this function will either load the login screen, homepage or access denied
  Future<void> _navigateToHome() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    LS().read('user').then((value) {
      if (value != null) {
        // User is already logged in

        // check if user has access to database
        FB().checkAccess().then((value) async {
          if (value == "rw") {
            // initialize local database
            await Record().init();

            // User has access to database
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }
          } else {
            // User does not have access to database
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AccessDenied()),
            );
          }
        });
      } else {
        // User is not logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
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
                image: AssetImage("assets/images/ic_launcher_hires.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
