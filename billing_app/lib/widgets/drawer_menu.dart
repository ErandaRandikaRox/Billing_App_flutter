import 'package:billing_app/pages/add%20stores/add_stores.dart';
import 'package:billing_app/pages/credit_bill/credit_bill_page.dart';
import 'package:billing_app/pages/pinned_bill/pinnied_bill.dart';
import 'package:billing_app/pages/salary/salary_page.dart';
import 'package:billing_app/pages/setting/setting.dart';
import 'package:billing_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  void logout(BuildContext context) {
    final authServices = AuthService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () async {
              await authServices.logout();
              Navigator.pop(context);
              // Navigate to login screen (adjust route as needed)
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
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
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Billing App",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
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
                  icon: Icons.money,
                  title: "Pinned Bill",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PinniedBill()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.credit_card,
                  title: "Credit Bill",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreditBillPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.money,
                  title: "Salary",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SalaryPage()),
                    );
                  },
                ),
                Divider(color: Theme.of(context).dividerColor),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Divider(color: Theme.of(context).dividerColor),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    "Log out",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  onTap: () => logout(context),
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
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}