import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/loading.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/toaster.dart';
import 'package:garuda/admin/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpFieldEnabled = false;
  bool _isSubmitButtonEnabled = false;
  bool _isSendOtpButtonEnabled = false;
  String? _verificationId;
  FirebaseAuth? _auth;
  String username = 'Unknown User';
  String _selectedRole = 'Volunteer';

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
    _mobileNumberController.addListener(_onMobileNumberChanged);
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    username = _usernameController.text;
    final isValidUsername = username.isNotEmpty;
    setState(() {
      _isSendOtpButtonEnabled = isValidUsername;
    });
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

  Future<void> _sendOTP() async {
    setState(() {
      _isSendOtpButtonEnabled = false;
      Toaster().info("Verifying");
    });

    final mobileNumber = '+91${_mobileNumberController.text}';
    loginUser(mobileNumber, LoginUserCallbacks(
      codeSent: (String verificationId, FirebaseAuth auth) {
        _verificationId = verificationId;
        _auth = auth;
        setState(() {
          _isOtpFieldEnabled = true;
        });
      },
    ));
  }

  Future<void> _submitOTP() async {
    if (_verificationId != null) {
      setState(() {
        _isSubmitButtonEnabled = false;
        Toaster().info("Logging in");
      });

      final code = _otpController.text.trim();
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: code);

      UserCredential result;
      try {
        result = await _auth!.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        Toaster().error("Error: $e");
        return;
      }

      User? user = result.user;

      if (user != null) {
        await LS().write(
          'username',
          username,
        );

        var u = UserDetails(
          uid: user.uid,
          name: username,
          phone: user.phoneNumber,
          role: _selectedRole,
        );
        LS().write('user_details', jsonEncode(u.toJson()));

        await FB().addPendingUser(u);

        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => LoadingScreen()));
        } else {
          Toaster().error("Error: context not mounted");
        }
      } else {
        Toaster().error("Verfication error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // name of the user
              TextFormField(
                controller:
                    _usernameController, // Define this controller in your class
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                keyboardType: TextInputType.text,
              ),

              // mobile number
              const SizedBox(
                  height:
                      16.0), // Spacing between username and mobile number fields
              TextFormField(
                controller: _mobileNumberController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixText: '+91',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),

              // Dropdown menu for role selection
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedRole, // Default value set to 'volunteer'
                decoration: const InputDecoration(
                  labelText: 'Role',
                ),
                items: <String>['Volunteer', 'Pujari', 'Security', 'Admin']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
              ),

              // verify button, which will send OTP
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isSendOtpButtonEnabled ? _sendOTP : null,
                child: const Text('Verify'),
              ),

              // OTP field
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                ),
                keyboardType: TextInputType.number,
                enabled: _isOtpFieldEnabled,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),

              // submit OTP button
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isSubmitButtonEnabled ? _submitOTP : null,
                child: const Text('Submit OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> loginUser(String phone, LoginUserCallbacks callbacks) async {
  FirebaseAuth auth = FirebaseAuth.instance;

  auth.verifyPhoneNumber(
    phoneNumber: phone,
    timeout: const Duration(seconds: 60),
    verificationCompleted: (AuthCredential credential) async {
      // Toaster().info("Auto verification disabled");
    },
    verificationFailed: (FirebaseAuthException exception) {
      Toaster().error("Verification failed: $exception");
    },
    codeSent: (String verificationId, int? resendToken) async {
      Toaster().info("OTP sent");
      callbacks.codeSent(verificationId, auth);
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      // Toaster().error("codeAutoRetrievalTimeout");
    },
  );
}

class LoginUserCallbacks {
  void Function(String verificationId, FirebaseAuth auth) codeSent;

  LoginUserCallbacks({
    required this.codeSent,
  });
}
