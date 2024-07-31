import 'package:flutter/material.dart';
import 'package:saloon_cult_admin/colors.dart';
import 'package:saloon_cult_admin/drawer/drawer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _OwnerdashboardState();
}

class _OwnerdashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primaryYellow,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const DashboardDrawer(),
      body: const SafeArea(
        child: Column(
          children: [
          ],
        ),
      ),
    );
  }
}
