import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/toaster.dart';
import 'package:garuda/user.dart';
import 'package:synchronized/synchronized.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _lockInit = Lock();
  List<UserDetails> _pendingUsers = [];
  List<UserDetails> _approvedUsers = [];

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

      // populate users list
      _pendingUsers = await FB().readPendingUsers();
      _approvedUsers = await FB().readApprovedUsers();
    });
  }

  Widget _widgetUsers() {
    return Column(
      children: [
        const Text(
          'Pending approvals',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _pendingUsers.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Column(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0), // Add horizontal padding
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey), // Set the border color
                                borderRadius: BorderRadius.circular(
                                    8), // Optional: Add rounded corners
                              ),
                              child: ListTile(
                                title: Text(_pendingUsers[index].name!),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Align children to the start (left)
                                  children: [
                                    Text(_pendingUsers[index].phone!),
                                    Text(_pendingUsers[index].role!),
                                  ],
                                ),

                                // approve or reject buttons
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors
                                            .green, // Set the icon color to green
                                      ),
                                      onPressed: () async {},
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors
                                            .red, // Set the icon color to red
                                      ),
                                      onPressed: () async {},
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Add space between each ListTile
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
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
            return _widgetUsers();
          }
        },
      ),
    );
  }
}
