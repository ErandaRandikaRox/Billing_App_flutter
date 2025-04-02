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
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: _getAppBarTitle(),
        actions: const [],
        showDrawerIcons: true,
        showBackButton: false,
      ),
      drawer: const CustomDrawer(), // Place the drawer here
      body: IndexedStack(index: currentPageIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
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
                /// Home
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home_rounded),
                  title: const Text("Home"),
                  selectedColor: Colors.deepPurple,
                  unselectedColor: Colors.grey[400],
                ),

                /// Add Bill
                SalomonBottomBarItem(
                  icon: const Icon(Icons.add_circle_rounded),
                  title: const Text("Add Bill"),
                  selectedColor: Colors.deepPurple,
                  unselectedColor: Colors.grey[400],
                ),

                /// Profile
                SalomonBottomBarItem(
                  icon: const Icon(Icons.person_rounded),
                  title: const Text("Profile"),
                  selectedColor: Colors.deepPurple,
                  unselectedColor: Colors.grey[400],
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
      leading:
          showDrawerIcons
              ? Builder(
                builder:
                    (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer(); // ✅ Opens the drawer
                      },
                    ),
              )
              : showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
              : null,
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
