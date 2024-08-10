import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saloon_cult_admin/Employ%20Side/empdata.dart';
import 'package:saloon_cult_admin/account/accountoption.dart';
import 'package:saloon_cult_admin/dashboard.dart';
import 'package:saloon_cult_admin/Employ%20Side/empdashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await UserData().loadUserData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  late Future<String> _navigationTarget;

  @override
  void initState() {
    super.initState();
    _navigationTarget = _checkLoginStatus();
  }

  Future<String> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(userId)
          .get();

      if (employeeDoc.exists) {
        return 'employee'; // Navigate to EmployeeDashboard
      } else {
        return 'dashboard'; // Navigate to Dashboard
      }
    } else {
      return 'login'; // Navigate to Accountoptionpage
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _navigationTarget,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          switch (snapshot.data!) {
            case 'employee':
              return const EmployeeDashboard(); // EmployeeDashboard for employees
            case 'dashboard':
              return const Dashboard(); // Dashboard for others
            case 'login':
            default:
              return const Accountoptionpage(); // Login page for unauthenticated users
          }
        }
        return const Center(child: Text('Error checking login status'));
      },
    );
  }
}
