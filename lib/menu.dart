import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garuda/admin/admin.dart';
import 'package:garuda/admin/user.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/loading.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/login.dart';
import 'package:garuda/pushpanjali/pushpanjali.dart';
import 'package:garuda/toaster.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  Widget _buildGridItem(String imagePath, String label, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(8.0), // Adjust the radius as needed
            child: Image.asset(
              imagePath,
              width: 50.0,
              height: 50.0,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'imagePath': 'assets/images/vishnu_pushpanjali.png',
        'label': 'Pushpanjali',
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Pushpanjali()),
          );
        }
      },
      {
        'imagePath': 'assets/images/laddu.jpg',
        'label': 'Prasadam',
        'action': () {
          Toaster().error("Not Implemented");
        }
      },
      {
        'imagePath': 'assets/images/deepotsava.jpg',
        'label': 'Deepotsava',
        'action': () {
          Toaster().error("Not Implemented!");
        }
      },
      {
        'imagePath': 'assets/images/admin.jpg',
        'label': 'Admin',
        'action': () async {
          // check if access to the page is there
          String? json = await LS().read('user_details');
          if (json != null) {
            UserDetails u = UserDetails.fromJson(jsonDecode(json));
            UserDetails user = await FB().getUserDetails(u.uid!);
            if (user.role != 'Admin') {
              Toaster().error("Access Denied!");
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminPage()),
              );
            }
          } else {
            Toaster().error("Unknown Error!");
          }
        }
      },
      {
        'imagePath': 'assets/images/settings.jpg',
        'label': 'Settings',
        'action': () {
          Toaster().error("Not Implemented");
        }
      },

      // log out
      {
        'imagePath': 'assets/images/logout.jpg',
        'label': 'Logout',
        'action': () {
          LS().delete('user_details');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoadingScreen()),
          );
        }
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hare Krishna'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = (constraints.maxWidth / 150).floor();
          return Center(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 0.0, // Reduced to zero
                crossAxisSpacing: 0.0, // Reduced to zero
                childAspectRatio: 1.0,
              ),
              padding: const EdgeInsets.all(30.0), // Reduced padding
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildGridItem(
                  items[index]['imagePath'],
                  items[index]['label'],
                  items[index]['action'],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
