import 'package:flutter/material.dart';
import 'package:garuda/admin/pending_users.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  PendingUsers _pendingUsersWidget = PendingUsers(key: keyPendingUsers);

  Future<void> _refresh() async {
    await keyPendingUsers.currentState!.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _pendingUsersWidget,
      ),
    );
  }
}
