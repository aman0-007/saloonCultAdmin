import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saloon_cult_admin/Authentication/authentication.dart';
import 'package:saloon_cult_admin/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ownermanage extends StatefulWidget {
  const Ownermanage({Key? key}) : super(key: key);

  @override
  State<Ownermanage> createState() => _OwnermanageState();
}

class _OwnermanageState extends State<Ownermanage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Authentication auth = Authentication();
  String _selectedSlotTime = '1hr'; // Default selected slot time

  Map<String, bool> _selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  Map<String, TimeOfDay> _openTimes = {
    'Monday': TimeOfDay(hour: 0, minute: 0),
    'Tuesday': TimeOfDay(hour: 0, minute: 0),
    'Wednesday': TimeOfDay(hour: 0, minute: 0),
    'Thursday': TimeOfDay(hour: 0, minute: 0),
    'Friday': TimeOfDay(hour: 0, minute: 0),
    'Saturday': TimeOfDay(hour: 0, minute: 0),
    'Sunday': TimeOfDay(hour: 0, minute: 0),
  };

  Map<String, TimeOfDay> _closeTimes = {
    'Monday': TimeOfDay(hour: 12, minute: 0),
    'Tuesday': TimeOfDay(hour: 12, minute: 0),
    'Wednesday': TimeOfDay(hour: 12, minute: 0),
    'Thursday': TimeOfDay(hour: 12, minute: 0),
    'Friday': TimeOfDay(hour: 12, minute: 0),
    'Saturday': TimeOfDay(hour: 12, minute: 0),
    'Sunday': TimeOfDay(hour: 12, minute: 0),
  };

  @override
  void initState() {
    super.initState();
    _fetchTimings();
  }

  Future<void> _fetchTimings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('shops').doc(userId).get();
        if (snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data()?['shopTimings'] as Map<String, dynamic>?;
          if (data != null) {
            setState(() {
              _selectedDays.forEach((day, _) {
                if (data.containsKey(day)) {
                  _selectedDays[day] = true;
                  var timing = data[day];
                  if (timing['status'] == 'closed') {
                    _openTimes[day] = TimeOfDay(hour: 0, minute: 0);
                    _closeTimes[day] = TimeOfDay(hour: 0, minute: 0);
                  } else {
                    _openTimes[day] = _timeFromString(timing['openTime']);
                    _closeTimes[day] = _timeFromString(timing['closeTime']);
                  }
                } else {
                  _selectedDays[day] = false;
                }
              });
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching timings: $e');
    }
  }

  TimeOfDay _timeFromString(String timeString) {
    final parts = timeString.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isAM = parts[1] == 'AM';

    return TimeOfDay(hour: isAM ? hour : hour + 12, minute: minute);
  }


  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: AppColors.primaryYellow, width: 2.0),
              ),
              backgroundColor: Colors.black,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Working Days',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(
                        color: AppColors.primaryYellow,
                        thickness: 1,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ..._selectedDays.keys.map((day) {
                      return Column(
                        children: [
                          _buildWeekdayToggle(day, _selectedDays[day]!, (value) {
                            setState(() {
                              _selectedDays[day] = value;
                            });
                          }),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: _selectedDays[day]!
                                ? AnimatedOpacity(
                              opacity: _selectedDays[day]! ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 300),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildTimePicker(
                                          'Open Time', _openTimes[day]!, (time) {
                                        setState(() {
                                          _openTimes[day] = time;
                                        });
                                      }),
                                      Text(
                                        ':',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      _buildTimePicker(
                                          'Close Time', _closeTimes[day]!, (time) {
                                        setState(() {
                                          _closeTimes[day] = time;
                                        });
                                      }),
                                    ],
                                  ),
                                  SizedBox(height: 16.0),
                                ],
                              ),
                            )
                                : SizedBox.shrink(),
                          ),
                        ],
                      );
                    }).toList(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        ElevatedButton(
                          onPressed: () async {
                            // Call saveShopTimings here to save the updated timings
                            await auth.saveShopTimings(_selectedDays, _openTimes, _closeTimes); // Call saveShopTimings from ShopTimingsService
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildWeekdayToggle(String day, bool isSelected, Function(bool) onChanged) {
    return Row(
      children: [
        Text(
          day,
          style: TextStyle(color: Colors.white),
        ),
        Spacer(),
        Switch(
          value: isSelected,
          onChanged: onChanged,
          activeColor: AppColors.primaryYellow,
          inactiveThumbColor: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay selectedTime, Function(TimeOfDay) onTimeChanged) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );
        if (pickedTime != null) {
          onTimeChanged(pickedTime);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryYellow),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text(
          '${selectedTime.format(context)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryYellow,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primaryYellow,
        title: const Text(
          'Manage Timings',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: AppColors.primaryYellow),
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Slot Time',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 18.0),
                          child: Container(
                            width: 120, // Adjusted width to fit content
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: AppColors.primaryYellow),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryYellow),
                                value: _selectedSlotTime,
                                style: TextStyle(color: AppColors.primaryYellow), // Default text color
                                dropdownColor: Colors.black,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedSlotTime = newValue!;
                                    auth.saveSlotTime(newValue);
                                  });
                                },
                                items: <String>['1hr', '30 min', '45 min', '20 min']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: AppColors.primaryYellow),
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        value,
                                        style: TextStyle(color: AppColors.primaryYellow),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 10,),

          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: AppColors.primaryYellow, width: 2.0), // Increased border width to 2.0
                borderRadius: BorderRadius.circular(10.0), // Rounded corners with radius 10.0
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Shop Timing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _showEditDialog, // Show dialog on edit icon click
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.edit,
                            color: AppColors.primaryYellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(
                      color: AppColors.primaryYellow,
                      thickness: 1,
                    ),
                  ),
                  ..._selectedDays.keys.map((day) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 8.0,bottom: 10.0),
                      child: Column(
                        children: [
                          _selectedDays[day]!
                              ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    day,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '${_openTimes[day]!.format(context)} - ${_closeTimes[day]!.format(context)}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                            ],
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                day,
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Closed',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
