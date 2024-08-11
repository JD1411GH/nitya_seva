import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/toaster.dart';
import 'package:garuda/user.dart';
import 'package:synchronized/synchronized.dart';

class PendingUsers extends StatefulWidget {
  PendingUsers({super.key});

  @override
  State<PendingUsers> createState() => _PendingUsersState();
}

class _PendingUsersState extends State<PendingUsers> {
  final _lockInit = Lock();
  List<UserDetails> _pendingUsers = [];

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      // populate users list
      _pendingUsers = await FB().readPendingUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _futureInit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else {
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            title: Text(_pendingUsers[index].name!),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_pendingUsers[index].phone!),
                                Text(_pendingUsers[index].role!),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () async {
                                    // Add your approve logic here
                                    await FB()
                                        .approveUser(_pendingUsers[index]);
                                    await _futureInit();
                                    setState(() {
                                      Toaster().info('User approved');
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () {
                                    // Add your reject logic here
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          }
        });
  }
}
