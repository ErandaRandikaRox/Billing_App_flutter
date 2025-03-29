import 'package:flutter/material.dart';
import 'package:billing_app/widgets/custom_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Settings",
          actions: [Icon(Icons.search)],
          showDrawerIcons: false,
          showBackButton: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Settings content goes here
                Text(
                  "Settings",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                // Add your settings options here
                _buildSettingItem(
                  context,
                  Icons.person,
                  "Account",
                  "Manage your account information",
                  () {
                    // Account settings action
                  },
                ),
                _buildSettingItem(
                  context,
                  Icons.notifications,
                  "Notifications",
                  "Configure notification preferences",
                  () {
                    // Notification settings action
                  },
                ),
                _buildSettingItem(
                  context,
                  Icons.color_lens,
                  "Appearance",
                  "Customize theme and display options",
                  () {
                    // Appearance settings action
                  },
                ),
                _buildSettingItem(
                  context,
                  Icons.privacy_tip,
                  "Privacy & Security",
                  "Manage privacy and security settings",
                  () {
                    // Privacy settings action
                  },
                ),
                _buildSettingItem(
                  context,
                  Icons.help_outline,
                  "Help & Support",
                  "Get assistance and support",
                  () {
                    // Help settings action
                  },
                ),
                _buildSettingItem(
                  context,
                  Icons.info_outline,
                  "About",
                  "App information and version",
                  () {
                    // About settings action
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade800),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
