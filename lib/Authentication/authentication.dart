import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saloon_cult_admin/Employ%20Side/empdashboard.dart';
import 'package:saloon_cult_admin/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saloon_cult_admin/account/Register.dart';

class Authentication {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  final Map<String, bool> _selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  final Map<String, TimeOfDay?> _openTimes = {};
  final Map<String, TimeOfDay?> _closeTimes = {};

  Future<void> registerShopWithEmailAndPassword(BuildContext context, String shopName, File profileImage, File bannerImage, Position currentPosition, String address, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user?.uid ?? '';

      String profileImageUrl = await _uploadImage(profileImage, userId, 'profile_image.jpg');
      String bannerImageUrl = await _uploadImage(bannerImage, userId, 'banner_image.jpg');

      await firestore.collection('shops').doc(userCredential.user?.uid).set({
        'shopName': shopName,
        'profileImage': profileImageUrl,
        'bannerImage': bannerImageUrl,
        'currentPosition': GeoPoint(currentPosition.latitude, currentPosition.longitude),
        'address': address,
        'email': email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop registration successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to register shop')),
      );
      print('Shop registration failed: $e');
    }
  }

  Future<String> _uploadImage(File image, String userId, String fileName) async {
    try {
      // Create a storage reference for the user-specific folder
      Reference ref = _storage.ref().child('images').child(userId).child(fileName);

      // Upload the image to the storage
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      // Get and return the download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Image upload failed: $e');
      return '';
    }
  }

  Future<void> signInWithEmailAndPassword(BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Save user ID to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.uid);

        // Check if the user ID exists in the employees collection
        DocumentSnapshot employeeSnapshot = await FirebaseFirestore.instance
            .collection('employees')
            .doc(user.uid)
            .get();

        if (employeeSnapshot.exists) {
          // Navigate to empdashboard if the user is an employee
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => EmployeeDashboard()));
        } else {
          // Navigate to the original destination if the user is not an employee
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dashboard()));
        }
      }
    } catch (e) {
      print('Sign-in failed: $e');
    }
  }


  Future<void> registerEmployeeWithEmailAndPassword(
      BuildContext context,
      String employeeName,
      String mobileNumber,
      String email,
      String password,
      File profileImage,
      ) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      // Generate a unique filename for the profile image
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String profileImageFilename = 'employee_image_$timestamp.jpg';

      // Upload profile image and get its URL
      String profileImageUrl = await _uploadImage(
        profileImage,
        userId!,
        profileImageFilename, // Use unique filename
      );

      // Save employee data to Firestore
      await firestore
          .collection('shops')
          .doc(userId)  // Use user's UID as the document ID
          .collection('employees')
          .doc(userCredential.user?.uid)
          .set({
        'employeeName': employeeName,
        'mobileNumber': mobileNumber,
        'email': email,
        'profileImage': profileImageUrl,
        'shopID':userId
      });

      await firestore.collection('employees').doc(userCredential.user?.uid).set({
        'name': employeeName,
        'mobile': mobileNumber,
        'email': email,
        'profileImage': profileImageUrl,
        'shopId': userId,  // Save the shop ID here
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee registration successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to register employee')),
      );
      print('Employee registration failed: $e');
    }
  }

  Future<void> addShopMenuItem(BuildContext context, String name, String price, String time) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId != null) {
        await firestore
            .collection('shops')
            .doc(userId)
            .collection('menu')
            .add({
          'menuName': name,
          'menuPrice': price,
          'menuTime': time,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu item added successfully')),
        );
      } else {
        throw Exception('No logged-in user found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add menu item')),
      );
      print('Menu adding failed: $e');
    }
  }

  Future<void> saveSlotTime(String slotTime) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId != null) {
        var shopRef = firestore.collection('shops').doc(userId);
        var shopDoc = await shopRef.get();

        if (shopDoc.exists) {
          await shopRef.update({'slotTime': slotTime});
        } else {
          await shopRef.set({'slotTime': slotTime});
        }

        print('Slot time updated successfully');
      } else {
        throw Exception('No logged-in user found');
      }
    } catch (e) {
      print('Error updating slot time: $e');
    }
  }

  Future<void> saveShopTimings(Map<String, bool> selectedDays, Map<String, TimeOfDay> openTimes, Map<String, TimeOfDay> closeTimes) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId != null) {
        var shopRef = firestore.collection('shops').doc(userId);
        var shopDoc = await shopRef.get();

        Map<String, Map<String, dynamic>> timings = {};

        selectedDays.forEach((day, isSelected) {
          if (isSelected) {
            timings[day] = {
              'openTime': _combineTime(openTimes[day]!),
              'closeTime': _combineTime(closeTimes[day]!),
            };
          } else {
            timings[day] = {'status': 'closed'};
          }
        });

        if (shopDoc.exists) {
          await shopRef.update({'shopTimings': timings});
        } else {
          await shopRef.set({'shopTimings': timings});
        }

        print('Shop timings updated successfully');
      } else {
        throw Exception('No logged-in user found');
      }
    } catch (e) {
      print('Error updating shop timings: $e');
    }
  }

  String _combineTime(TimeOfDay time) {
    final isAM = time.hour < 12;
    final hourIn12Format = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final amPm = isAM ? 'AM' : 'PM';

    return '${hourIn12Format.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $amPm';
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      final auth = FirebaseAuth.instance;

      await auth.signOut();

      // Clear SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Register()),  // Replace with your actual page
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign out')),
      );
    }
  }
}
