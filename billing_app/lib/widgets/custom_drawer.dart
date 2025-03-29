// custom_drawer.dart
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Icon(Icons.delivery_dining, color: Colors.white, size: 64),
          ),
          ListTile(
            leading: Icon(Icons.store),
            title: Text("Store name"),
            onTap: () {
              // Handle navigation
              Navigator.pop(context); // Close the drawer
            },
          ),
          // Add more list tiles as needed
        ],
      ),
    );
  }
}
