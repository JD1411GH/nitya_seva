import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
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
                      return ListTile(
                        title: Text(_pendingUsers[index].name!),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_pendingUsers[index].phone!),
                              Text(_pendingUsers[index].role!),
                            ]),
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
