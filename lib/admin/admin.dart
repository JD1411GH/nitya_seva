import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garuda/admin/pending_users.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/toaster.dart';
import 'package:garuda/admin/user.dart';
import 'package:synchronized/synchronized.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _lockInit = Lock();

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      // check if access to the page is there
      String? json = await LS().read('user_details');
      if (json != null) {
        UserDetails u = UserDetails.fromJson(jsonDecode(json));
        UserDetails user = await FB().getUserDetails(u.uid!);
        if (user.role != 'Admin') {
          Toaster().error("Access Denied!");
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      } else {
        Toaster().error("Unknown Error!");
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
      ),
      body: FutureBuilder<void>(
        future: _futureInit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else {
            return PendingUsers();
          }
        },
      ),
    );
  }
}
