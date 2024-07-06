import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

Future<void> loginUser(String phone) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  _auth.verifyPhoneNumber(
    phoneNumber: phone,
    timeout: const Duration(seconds: 60),
    verificationCompleted: (AuthCredential credential) async {
      UserCredential result = await _auth.signInWithCredential(credential);

      User? user = result.user;

      if (user != null) {
        print("Verfication Completed");
      } else {
        print("Error");
      }
    },
    verificationFailed: (FirebaseAuthException exception) {
      print(exception);
    },
    codeSent: (String verificationId, int? resendToken) async {
      final code = stdin.readLineSync()!.trim();
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);

      UserCredential result = await _auth.signInWithCredential(credential);

      User? user = result.user;

      if (user != null) {
        // Navigate to your desired screen
        print("codeSent");
      } else {
        print("Error");
      }
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      print("codeAutoRetrievalTimeout");
    },
  );
}
