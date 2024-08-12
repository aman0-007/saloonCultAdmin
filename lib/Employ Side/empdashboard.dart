import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saloon_cult_admin/Employ%20Side/empdrawer.dart';
import 'package:saloon_cult_admin/colors.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  String? _userName;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('employees').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'];
          _profileImageUrl = userDoc['profileImage'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primaryYellow,
        title: const Text(
          'Employee Dashboard',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: EmployeeDrawer(),
      body: const SafeArea(
        child: Column(
          children: [
            // Your dashboard content here
          ],
        ),
      ),
    );
  }
}
