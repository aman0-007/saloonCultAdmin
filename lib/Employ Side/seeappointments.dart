import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeeAppointments extends StatefulWidget {
  const SeeAppointments({super.key});

  @override
  State<SeeAppointments> createState() => _SeeAppointmentsState();
}

class _SeeAppointmentsState extends State<SeeAppointments> {
  late Future<String?> _employeeIdFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the employee ID future
    _employeeIdFuture = _getEmployeeId();
    print(_employeeIdFuture);
  }

  Future<String?> _getEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<List<Map<String, dynamic>>> _fetchAppointments(String employeeId) async {
    List<Map<String, dynamic>> appointments = [];

    // Query Firestore for appointments
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('employees')
        .doc(employeeId)
        .collection('appointmentsCreated')
        .get();

    for (var doc in snapshot.docs) {
      appointments.add(doc.data() as Map<String, dynamic>);
    }

    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('See Appointments'),
        backgroundColor: Colors.yellow,
      ),
      body: FutureBuilder<String?>(
        future: _employeeIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error fetching employee ID.'));
          } else {
            String? employeeId = snapshot.data;
            if (employeeId == null) {
              return const Center(child: Text('Employee ID not found.'));
            }

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchAppointments(employeeId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching appointments.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No appointments found.'));
                } else {
                  List<Map<String, dynamic>> appointments = snapshot.data!;
                  return ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return ListTile(
                        title: Text('Booking ID: ${appointment['bookingId']}'),
                        subtitle: Text('Date: ${appointment['selectedDate']}\n'
                            'Time Slot: ${appointment['selectedTimeSlot']}\n'
                            'Customer Name: ${appointment['customerName']}'),
                        isThreeLine: true,
                        contentPadding: const EdgeInsets.all(16),
                        tileColor: Colors.grey[200],
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
