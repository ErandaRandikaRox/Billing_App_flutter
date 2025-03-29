import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text('Billing App')),
          ListTile(
            title: const Text(''),
            onTap: () {
              Navigator.pop(context);
            },  
          )
        ],
      ),
    );
  }
}
