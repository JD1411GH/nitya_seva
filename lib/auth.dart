import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpFieldEnabled = false;
  bool _isSubmitButtonEnabled = false;
  bool _isSendOtpButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _mobileNumberController.addListener(_onMobileNumberChanged);
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onMobileNumberChanged() {
    final mobileNumber = _mobileNumberController.text;
    final isValidMobileNumber = RegExp(r'^\d{10}$').hasMatch(mobileNumber);
    setState(() {
      _isSendOtpButtonEnabled = isValidMobileNumber;
    });
  }

  void _onOtpChanged() {
    final otp = _otpController.text;
    setState(() {
      _isSubmitButtonEnabled = otp.isNotEmpty;
    });
  }

  void _sendOTP() {
    // Your logic to send OTP
    setState(() {
      _isOtpFieldEnabled = true;
    });
  }

  void _submitOTP() {
    // Your logic to submit OTP
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _mobileNumberController,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+91',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isSendOtpButtonEnabled ? _sendOTP : null,
              child: Text('Send OTP'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'OTP',
              ),
              keyboardType: TextInputType.number,
              enabled: _isOtpFieldEnabled,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isSubmitButtonEnabled ? _submitOTP : null,
              child: Text('Submit OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

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
