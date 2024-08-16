import 'package:flutter/material.dart';
import 'package:saloon_cult_admin/Authentication/authentication.dart';
import 'package:saloon_cult_admin/Employ%20Side/appointments.dart';
import 'package:saloon_cult_admin/Employ%20Side/empdashboard.dart';
import 'package:saloon_cult_admin/Employ%20Side/empdata.dart';
import 'package:saloon_cult_admin/account/accountoption.dart';
import 'package:saloon_cult_admin/colors.dart';

class EmployeeDrawer extends StatelessWidget {
  const EmployeeDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = UserData(); // Get user data singleton instance

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primaryYellow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: userData.profileImageUrl != null
                        ? NetworkImage(userData.profileImageUrl!)
                        : null,
                    child: userData.profileImageUrl == null
                        ? const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primaryYellow,
                    )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    userData.userName ?? 'Loading...',
                    style: const TextStyle(
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
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmployeeDashboard()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: AppColors.primaryYellow),
                    title: const Text('Profile', style: TextStyle(color: AppColors.primaryYellow)),
                    onTap: () {
                      Navigator.pop(context);
                      // Add navigation to profile page if needed
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: AppColors.primaryYellow),
                    title: const Text('Appointments', style: TextStyle(color: AppColors.primaryYellow)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Appointments()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: AppColors.primaryYellow),
                    title: const Text('Manage', style: TextStyle(color: AppColors.primaryYellow)),
                    onTap: () {
                      // Navigator.pop(context);
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
                    onTap: () async {
                      final auth = Authentication();
                      await auth.signOut(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Accountoptionpage()),
                      );
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
