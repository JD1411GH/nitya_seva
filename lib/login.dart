import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nitya_seva/access_denied.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/firebase.dart';
import 'package:nitya_seva/home.dart';
import 'package:nitya_seva/loading.dart';
import 'package:nitya_seva/toaster.dart';

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

  void _sendOTP() {
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
        await DB().write('user', user.toString());
        await DB().write(
          'username',
          username,
        );

        Toaster().info("Login successful");

        if (mounted) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoadingScreen()));
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller:
                    _usernameController, // Define this controller in your class
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                keyboardType: TextInputType.text,
              ),
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
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isSendOtpButtonEnabled ? _sendOTP : null,
                child: const Text('Send OTP'),
              ),
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
      Toaster().info("Auto verification disabled");
      // UserCredential result = await _auth.signInWithCredential(credential);

      // User? user = result.user;

      // if (user != null) {
      //   print("Auto Verfication Completed $user");
      // } else {
      //   print("Error");
      // }
    },
    verificationFailed: (FirebaseAuthException exception) {
      Toaster().error("Verification failed: $exception");
    },
    codeSent: (String verificationId, int? resendToken) async {
      callbacks.codeSent(verificationId, auth);
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      Toaster().error("codeAutoRetrievalTimeout");
    },
  );
}

class LoginUserCallbacks {
  void Function(String verificationId, FirebaseAuth auth) codeSent;

  LoginUserCallbacks({
    required this.codeSent,
  });
}
