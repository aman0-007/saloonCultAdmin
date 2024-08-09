import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:saloon_cult_admin/colors.dart';
import 'package:saloon_cult_admin/drawer/drawer.dart';
import 'package:saloon_cult_admin/employee/addemployee.dart';
import 'package:saloon_cult_admin/employee/updateemployee.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Employeemangement extends StatefulWidget {
  const Employeemangement({super.key});

  @override
  State<Employeemangement> createState() => _EmployeemangementState();
}

class _EmployeemangementState extends State<Employeemangement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId; // Store the user ID
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  void _deleteEmployee(String employeeId) async {
    try {
      await _firestore
          .collection('shops')
          .doc(_userId)
          .collection('employees')
          .doc(employeeId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete employee: $e')),
      );
    }
  }

  void _showUpdateEmployeeDialog(String employeeId, String? name, String? email, String? phone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Update Employee',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryYellow),
                  ),
                  const SizedBox(height: 16.0),
                  UpdateEmployeeForm(
                    initialName: name,
                    initialEmail: email,
                    initialPhone: phone,
                    employeeId: employeeId,
                    onSave: (name, email, phone) {
                      _updateEmployee(employeeId, name, email, phone);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateEmployee(String employeeId, String name, String email, String phone) async {
    try {
      await _firestore
          .collection('shops')
          .doc(_userId)
          .collection('employees')
          .doc(employeeId)
          .update({
        'employeeName': name,
        'email': email,
        'mobileNumber': phone,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update employee: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        backgroundColor: AppColors.primaryYellow,
        title: const Text(
          'Manage Employees',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const DashboardDrawer(),
      body: _userId == null
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query.toLowerCase();
                  });
                },
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
          // Display Employee Data
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('shops')
                  .doc(_userId)
                  .collection('employees')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No employees found.'));
                }

                final employees = snapshot.data!.docs;
                final filteredEmployees = employees.where((employee) {
                  final data = employee.data() as Map<String, dynamic>;
                  final name = data['employeeName']?.toLowerCase() ?? '';
                  return name.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = filteredEmployees[index];
                    final data = employee.data() as Map<String, dynamic>;
                    final employeeId = employee.id; // Get the document ID
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data['profileImage'] ?? ''),
                        backgroundColor: Colors.grey[200],
                      ),
                      title: Text(data['employeeName']),
                      subtitle: Text('${data['email']}\n${data['mobileNumber']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.primaryYellow),
                            onPressed: () {
                              _showUpdateEmployeeDialog(
                                employeeId,
                                data['employeeName'],
                                data['email'],
                                data['mobileNumber'],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmationDialog(employeeId);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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

  void _showDeleteConfirmationDialog(String employeeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this employee?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteEmployee(employeeId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add Employee',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryYellow),
                  ),
                  const SizedBox(height: 16.0),
                  EmployeeForm(
                    onFormSubmitted: () {
                      setState(() {
                        // Refresh employee data here
                        _loadUserId(); // Reload userId to refresh the data
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
