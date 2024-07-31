import 'package:flutter/material.dart';
import 'package:saloon_cult_admin/colors.dart';
import 'package:saloon_cult_admin/dashboard.dart';
import 'package:saloon_cult_admin/employee/manageemployee.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryYellow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Dashboard Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.home, color: AppColors.primaryYellow),
                    title: const Text('Home', style: TextStyle(color: AppColors.primaryYellow)),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Dashboard()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: AppColors.primaryYellow),
                    title: const Text('Profile', style: TextStyle(color: AppColors.primaryYellow)),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const Shopprofile()),
                      // );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu, color: AppColors.primaryYellow),
                    title: const Text('Menu', style: TextStyle(color: AppColors.primaryYellow)),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const Menumanagement()),
                      // );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people, color: AppColors.primaryYellow),
                    title: const Text('Employee', style: TextStyle(color: AppColors.primaryYellow)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Employeemangement()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: AppColors.primaryYellow),
                    title: const Text('Appointments', style: TextStyle(color: AppColors.primaryYellow)),
                    onTap: () {
                      // Navigate to appointments
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: AppColors.primaryYellow),
                    title: const Text('Manage', style: TextStyle(color: AppColors.primaryYellow)),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const Ownermanage()),
                      // );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                    title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      // Perform sign out
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
