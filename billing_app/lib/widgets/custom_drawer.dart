import 'package:billing_app/pages/add%20stores/add_stores.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.delivery_dining,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Delivery App",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.store,
                  title: "Add Stores",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddStores()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.credit_card,
                  title: "Credit Bill",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to credit bill page
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.money,
                  title: "Salary",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to salary page
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.money,
                  title: "Pined Bill",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to salary page
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings page
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Log out",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Handle logout
                    Navigator.pop(context);
                    // Implement logout functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
