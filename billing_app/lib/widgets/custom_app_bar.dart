import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:billing_app/pages/home/home_page.dart';
import 'package:billing_app/pages/root/root.dart';
import 'package:billing_app/pages/profile/profile.dart';

class MyNavigationbar extends StatefulWidget {
  const MyNavigationbar({super.key});

  @override
  State<MyNavigationbar> createState() => _MyNavigationbarState();
}

class _MyNavigationbarState extends State<MyNavigationbar> {
  int currentPageIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MakeRootPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine brightness for system UI
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: _getAppBarTitle(),
        actions: const [],
        showDrawerIcons: true,
        showBackButton: false,
      ),
      drawer: const CustomDrawer(),
      body: IndexedStack(index: currentPageIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SalomonBottomBar(
              currentIndex: currentPageIndex,
              onTap: (index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home_rounded),
                  title: const Text("Home"),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  unselectedColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.add_circle_rounded),
                  title: const Text("Add Bill"),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  unselectedColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.person_rounded),
                  title: const Text("Profile"),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  unselectedColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get the appropriate title based on current page
  String _getAppBarTitle() {
    switch (currentPageIndex) {
      case 0:
        return "Home";
      case 1:
        return "Add Bill";
      case 2:
        return "Profile";
      default:
        return "Billing App";
    }
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final bool showDrawerIcons;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.actions,
    required this.showDrawerIcons,
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showDrawerIcons
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            )
          : showBackButton
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : null,
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      actions: actions,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}