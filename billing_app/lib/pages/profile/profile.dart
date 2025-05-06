import 'package:billing_app/pages/loging/loging.dart';
import 'package:billing_app/services/auth/auth_service.dart';
import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:billing_app/pages/home/home_page.dart';
import 'package:billing_app/pages/root/root.dart';
// Import your login page (adjust the path as needed)

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentNavIndex = 2; // Track bottom navigation bar index (2 for Profile)
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData; // Store fetched user data
  bool _isLoading = true; // Track loading state
  String? _errorMessage; // Store error message if fetch fails

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      User? user = _authService.getCurrentUser();
      if (user == null) {
        setState(() {
          _errorMessage = 'No user is logged in';
          _isLoading = false;
        });
        return;
      }

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'User data not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching user data: $e';
        _isLoading = false;
      });
    }
  }

  // Handle logout
  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      if (mounted) {
        // Navigate to LoginPage and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Login()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Profile Page",
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // TODO: Implement edit profile functionality
            },
          ),
        ],
        showDrawerIcons: true,
        showBackButton: false,
      ),
      drawer: const CustomDrawer(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildProfileContent(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProfileContent() {
    // Format joined date
    String joinedDate = 'Unknown';
    if (_userData?['createdAt'] != null) {
      Timestamp? timestamp = _userData?['createdAt'] as Timestamp?;
      if (timestamp != null) {
        joinedDate = DateFormat('MMMM d, yyyy').format(timestamp.toDate());
      }
    }

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                _userData?['username'] ?? 'No Name',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _userData?['email'] ?? 'No Email',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              _buildInfoCard(
                "Phone",
                _userData?['phone'] ?? 'Not Provided',
                Icons.phone,
              ),
              _buildInfoCard(
                "Address",
                _userData?['address'] ?? 'Not Provided',
                Icons.location_on,
              ),
              _buildInfoCard("Joined", joinedDate, Icons.calendar_today),
              _buildInfoCard(
                "Salary / Month",
                _userData?['salary'] ?? 'Not Provided',
                Icons.attach_money,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _handleLogout,
                  child: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Padding to avoid overlap
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
            currentIndex: _currentNavIndex,
            onTap: (index) {
              setState(() {
                _currentNavIndex = index;
              });
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MakeRootPage()),
                );
              }
            },
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home_rounded),
                title: const Text("Home"),
                selectedColor: Colors.deepPurple,
                unselectedColor: Colors.grey[400],
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.add_circle_rounded),
                title: const Text("Add Bill"),
                selectedColor: Colors.deepPurple,
                unselectedColor: Colors.grey[400],
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.person_rounded),
                title: const Text("Profile"),
                selectedColor: Colors.deepPurple,
                unselectedColor: Colors.grey[400],
              ),
            ],
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade700,
          ),
        ),
        subtitle: Text(value, style: TextStyle(color: Colors.grey.shade600)),
      ),
    );
  }
}
