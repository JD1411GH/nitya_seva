import 'package:flutter/material.dart';
import 'package:garuda/admin/admin.dart';
import 'package:garuda/pushpanjali/pushpanjali.dart';

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
          // Define your custom action here
          print('Prasadam clicked');
        }
      },
      {
        'imagePath': 'assets/images/deepotsava.jpg',
        'label': 'Deepotsava',
        'action': () {
          // Define your custom action here
          print('Deepotsava clicked');
        }
      },
      {
        'imagePath': 'assets/images/admin.jpg',
        'label': 'Admin',
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminPage()),
          );
        }
      },
      {
        'imagePath': 'assets/images/settings.jpg',
        'label': 'Settings',
        'action': () {
          // Define your custom action here
          print('Settings clicked');
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
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
                childAspectRatio: 1.0,
              ),
              padding: const EdgeInsets.all(20.0),
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
