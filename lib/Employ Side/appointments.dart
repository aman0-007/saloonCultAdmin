import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saloon_cult_admin/Employ%20Side/empdata.dart';
import 'package:saloon_cult_admin/Employ%20Side/empdrawer.dart';
import 'package:saloon_cult_admin/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Appointments extends StatefulWidget {
  const Appointments({super.key});

  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  int _selectedIndex = 0; // Track the selected date box
  Map<String, dynamic>? _shopTimings; // To store shop timings
  String _statusMessage = ''; // To store status message for closed days
  late String _employeeId; // Employee ID
  Map<String, String> defaultTimeSlots = {};


  @override
  void initState() {
    super.initState();
    _fetchShopTimings();
    _fetchEmployeeId();
  }

  Future<void> _fetchShopTimings() async {
    String? shopId = UserData.instance.shopId;

    if (shopId != null) {
      try {
        DocumentSnapshot shopDoc = await FirebaseFirestore.instance.collection('shops').doc(shopId).get();
        if (shopDoc.exists) {
          var shopTimingsData = shopDoc['shopTimings'];
          if (shopTimingsData is Map) {
            _shopTimings = Map<String, dynamic>.from(shopTimingsData as Map<dynamic, dynamic>);
            setState(() {
              print('Fetched shop timings: $_shopTimings');
            });
          } else {
            print('Unexpected data type for shop timings: ${shopTimingsData.runtimeType}');
          }
        } else {
          print('Shop document does not exist.');
        }
      } catch (e) {
        print('Error fetching shop timings: $e');
      }
    } else {
      print('Shop ID is null.');
    }
  }

  Future<void> _fetchEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? employeeId = prefs.getString('userId');
    if (employeeId != null) {
      setState(() {
        _employeeId = employeeId;
      });
    }
  }

  Map<String, dynamic> convertToMap(String key, dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value as Map<dynamic, dynamic>);
    } else {
      throw ArgumentError('Value must be of type Map');
    }
  }

  Widget _buildDateSelector() {
    DateTime today = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            'Date',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(7, (index) {
              DateTime date = today.add(Duration(days: index));
              bool isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    _selectedIndex = index;
                  });
                  _updateStatusMessage(date); // Update status message based on selected date
                  await _handleNewDay(date); // Handle new day logic
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFfed60b) : const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFF212121)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('d').format(date), // Display date (e.g., 8)
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white.withOpacity(0.7), // Dimmed color for non-selected dates
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('EEE').format(date), // Display day (e.g., Mon)
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white.withOpacity(0.5), // Dimmed color for non-selected days
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            'Time',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), // Dimmed color for Time
          ),
        ),
        _buildTimeBlocks(),
      ],
    );
  }

  Future<void> _handleNewDay(DateTime date) async {
    try {
      // Initialize time slots
      defaultTimeSlots = _initializeTimeSlotsFromShopTimings(date); // Initialize time slots

      print('Time slots for ${DateFormat('yyyy-MM-dd').format(date)}:');
      defaultTimeSlots.forEach((time, status) {
        print('$time: $status');
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        print('User ID not found.');
        return;
      }

      print('User ID is : $userId');

      // Reference to the appointments collection
      CollectionReference appointmentsCollection = FirebaseFirestore.instance
          .collection('employees')
          .doc(userId)
          .collection('appointments');

      print("Preparing to create month document...");

      String monthYear = DateFormat('MMMM yyyy').format(date);
      DocumentReference monthDocRef = appointmentsCollection.doc(monthYear);

      DocumentSnapshot monthDoc = await monthDocRef.get();
      if (!monthDoc.exists) {
        try {
          // Create an empty document with dummy data
          await monthDocRef.set({'initialized': true});
          print('Successfully created empty document.');
        } catch (e) {
          print('Error creating document: $e');
        }
      } else {
        print('Month document already exists for $monthYear.');
      }

      // Create or update the day document with time slots directly
      DocumentReference dayDocRef = monthDocRef.collection('days').doc(DateFormat('yyyy-MM-dd').format(date));

      DocumentSnapshot dayDoc = await dayDocRef.get();
      if (!dayDoc.exists) {
        await dayDocRef.set({
          'timeSlots': defaultTimeSlots
        });
        print('Created new day document for ${DateFormat('yyyy-MM-dd').format(date)}.');
      } else {
        print('Day document already exists for ${DateFormat('yyyy-MM-dd').format(date)}.');
      }

    } catch (e) {
      print('Error handling new day: $e');
    }
  }

  Map<String, String> _initializeTimeSlotsFromShopTimings(DateTime date) {
    if (_shopTimings == null) {
      return {}; // Return an empty map if shop timings are not available
    }

    String dayName = DateFormat('EEEE').format(date); // Get the full name of the day (e.g., Monday)
    var timings = _shopTimings?[dayName];

    if (timings == null || !(timings is Map)) {
      print('Invalid timings data for $dayName: $timings');
      return {}; // Return an empty map if no timings are available or data is not in the expected format
    }

    // Convert to Map<String, String>
    Map<String, String> timingsMap = timings.map<String, String>((key, value) =>
        MapEntry(key.toString(), value.toString()));

    TimeOfDay openTime = _parseTime(timingsMap['openTime'] ?? '');
    TimeOfDay closeTime = _parseTime(timingsMap['closeTime'] ?? '');

    Map<String, String> slots = {};
    DateTime currentTime = DateTime(
      date.year,
      date.month,
      date.day,
      openTime.hour,
      openTime.minute,
    );

    DateTime closeDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      closeTime.hour,
      closeTime.minute,
    );

    // Handle case where shop closes past midnight
    if (closeTime.hour < openTime.hour || (closeTime.hour == openTime.hour && closeTime.minute < openTime.minute)) {
      closeDateTime = closeDateTime.add(const Duration(days: 1));
    }

    while (currentTime.isBefore(closeDateTime)) {
      String timeStr = DateFormat('h:mm a').format(currentTime);
      slots[timeStr] = 'no';
      currentTime = currentTime.add(const Duration(minutes: 60));
    }

    return slots;
  }

  Widget _buildTimeBlocks() {
    if (_shopTimings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    DateTime selectedDate = DateTime.now().add(Duration(days: _selectedIndex));
    String dayName = DateFormat('EEEE').format(selectedDate);

    var timings = _shopTimings![dayName];
    if (timings == null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFF212121)),
          ),
          child: Text(
            'Enjoy Holiday',
            style: const TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ),
      );
    }

    String? openTimeStr = timings['openTime'] as String?;
    String? closeTimeStr = timings['closeTime'] as String?;

    if (openTimeStr == null || closeTimeStr == null) {
      return Center(
        child: Text(
          'Invalid Timing Data',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18.0),
        ),
      );
    }

    TimeOfDay openTime = _parseTime(openTimeStr);
    TimeOfDay closeTime = _parseTime(closeTimeStr);

    List<Widget> timeBlocks = [];
    DateTime currentTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      openTime.hour,
      openTime.minute,
    );

    DateTime closeDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      closeTime.hour,
      closeTime.minute,
    );

    if (closeTime.hour < openTime.hour || (closeTime.hour == openTime.hour && closeTime.minute < openTime.minute)) {
      closeDateTime = closeDateTime.add(const Duration(days: 1));
    }

    while (currentTime.isBefore(closeDateTime)) {
      String timeSlot = DateFormat('h:mm a').format(currentTime);
      String status = defaultTimeSlots[timeSlot] ?? 'no';

      Color backgroundColor;
      Color borderColor;
      Color textColor;

      switch (status) {
        case 'booked':
          backgroundColor = Colors.yellow;
          borderColor = Colors.black;
          textColor = Colors.black;
          break;
        case 'no':
          backgroundColor = const Color(0xFF171717);
          borderColor = const Color(0xFF212121).withOpacity(0.5); // Dimmed border color
          textColor = Colors.white.withOpacity(0.7); // Dimmed text color
          break;
        default:
          backgroundColor = Colors.grey;
          borderColor = Colors.black;
          textColor = Colors.white;
      }

      timeBlocks.add(
        GestureDetector(
          onTap: () => _handleTimeSlotTap(timeSlot),
          child: Container(
            width: (MediaQuery.of(context).size.width - 40) / 2,
            height: 50.0,
            margin: const EdgeInsets.only(left: 9.0, right: 4.0, top: 4.0, bottom: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Text(
                timeSlot,
                style: TextStyle(color: textColor, fontSize: 14.0),
              ),
            ),
          ),
        ),
      );
      currentTime = currentTime.add(const Duration(hours: 1));
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: timeBlocks,
    );
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      DateTime dateTime = DateFormat('h:mm a').parse(timeStr);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      print('Error parsing time: $e');
      return const TimeOfDay(hour: 0, minute: 0); // Handle error or default value
    }
  }

  Future<void> _updateTimeSlotStatus(String timeSlot, String newStatus, DateTime selectedDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found.');
      return;
    }

    String monthYear = DateFormat('MMMM yyyy').format(selectedDate);
    DocumentReference dayDocRef = FirebaseFirestore.instance
        .collection('employees')
        .doc(userId)
        .collection('appointments')
        .doc(monthYear)
        .collection('days')
        .doc(DateFormat('yyyy-MM-dd').format(selectedDate));

    try {
      await dayDocRef.update({
        'timeSlots.$timeSlot': newStatus,
      });
      print('Time slot updated successfully.');
      _fetchShopTimings(); // Refresh the data
      setState(() {}); // Refresh the UI
    } catch (e) {
      print('Error updating time slot: $e');
    }
  }

  Future<void> _handleTimeSlotTap(String timeSlot) async {
    // Get the currently selected date
    DateTime selectedDate = DateTime.now().add(Duration(days: _selectedIndex));

    String currentStatus = await _getTimeSlotStatus(timeSlot, selectedDate); // Pass selectedDate

    String action;
    if (currentStatus == 'no') {
      action = 'disable';
    } else if (currentStatus == 'yes') {
      action = 'enable';
    } else if (currentStatus == 'booked') {
      action = 'view details'; // Or any other action if needed
    } else {
      action = 'unknown'; // For unknown statuses
    }

    if (action != 'view details') {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure you want to $action this time slot?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        String newStatus = currentStatus == 'yes' ? 'no' : 'yes';
        await _updateTimeSlotStatus(timeSlot, newStatus, selectedDate); // Pass selectedDate
      }
    } else {
      // Handle viewing details for booked slots if needed
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Slot Booked'),
            content: Text('This slot is booked by a customer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<String> _getTimeSlotStatus(String timeSlot, DateTime selectedDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found.');
      return 'no'; // Default value
    }

    String monthYear = DateFormat('MMMM yyyy').format(selectedDate);
    DocumentReference dayDocRef = FirebaseFirestore.instance
        .collection('employees')
        .doc(userId)
        .collection('appointments')
        .doc(monthYear)
        .collection('days')
        .doc(DateFormat('yyyy-MM-dd').format(selectedDate));

    try {
      DocumentSnapshot dayDoc = await dayDocRef.get();
      if (dayDoc.exists) {
        // Ensure the data is a Map<String, dynamic>
        var data = dayDoc.data();
        if (data != null && data is Map<String, dynamic>) {
          var timeSlots = data['timeSlots'];
          if (timeSlots is Map<String, dynamic>) {
            // Safely retrieve the time slot status
            return timeSlots[timeSlot] as String? ?? 'no';
          }
        }
        return 'no'; // Default value if not found
      }
      return 'no'; // Default value if document does not exist
    } catch (e) {
      print('Error fetching time slot status: $e');
      return 'no'; // Default value in case of error
    }
  }

  void _updateStatusMessage(DateTime date) {
    String dayName = DateFormat('EEEE').format(date);
    var timings = _shopTimings?[dayName];

    if (timings == null || (timings['status'] as String?) == 'closed') {
      setState(() {
        _statusMessage = 'Enjoy Holiday';
      });
    } else {
      setState(() {
        _statusMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Background color
      appBar: AppBar(
        backgroundColor: AppColors.primaryYellow,
        title: const Text(
          'Appointments',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const EmployeeDrawer(), // Assuming EmployeeDrawer is already implemented
      body: SafeArea(
        child: Column(
          children: [
            _buildDateSelector(),
            if (_statusMessage.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
