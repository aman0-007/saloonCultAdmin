import 'package:flutter/material.dart';
import 'package:saloon_cult_admin/Authentication/authentication.dart';
import 'package:saloon_cult_admin/colors.dart';
import 'package:saloon_cult_admin/drawer/drawer.dart';
import 'package:saloon_cult_admin/employee/addemployee.dart';
class Employeemangement extends StatefulWidget {
  const Employeemangement({super.key});

  @override
  State<Employeemangement> createState() => _EmployeemangementState();
}

class _EmployeemangementState extends State<Employeemangement> {
  final Authentication _employeeService = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primaryYellow,
        title: const Text(
          'Manage Employees',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const DashboardDrawer(),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Search TextBox
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryYellow),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                ),
              ),
            ),
            // Additional content goes here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryYellow,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _showAddEmployeeDialog(context);
        },
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Employee',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryYellow),
                ),
                const SizedBox(height: 16.0),
                EmployeeForm(employeeService: _employeeService),
              ],
            ),
          ),
        );
      },
    );
  }
}
