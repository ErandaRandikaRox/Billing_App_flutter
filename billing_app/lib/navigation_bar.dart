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
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      drawer: CustomDrawer(), // Place the drawer here
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
}
