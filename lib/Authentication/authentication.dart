import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saloon_cult_admin/account/Register.dart';

// Authentication class for handling Firebase Auth, Firestore, and Storage
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

  Authentication() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print('User is signed in: ${user.email}');
      } else {
        print('User is signed out');
      }
    });
  }

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
        'address' : address,
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


  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      return user;
    } catch (e) {
      print('Sign-in failed: $e');
      return null;
    }
  }

  Future<void> registerEmployeeWithEmailAndPassword(BuildContext context, String employeeName, String mobileNumber, String email, String password, File profileImage) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the newly created user's UID
      String userId = userCredential.user?.uid ?? '';

      // Upload profile image and get its URL
      String profileImageUrl = await _uploadImage(profileImage, userId, 'profile_image.jpg');


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
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await firestore
            .collection('shops')
            .doc(currentUser.uid)
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
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        var shopRef = firestore.collection('shops').doc(currentUser.uid);
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

  Future<void> saveShopTimings() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        var shopRef = firestore.collection('shops').doc(currentUser.uid);
        var shopDoc = await shopRef.get();

        Map<String, Map<String, dynamic>> timings = {};

        _selectedDays.forEach((day, isSelected) {
          if (isSelected) {
            timings[day] = {
              'openTime': _combineTime(_openTimes[day]!),
              'closeTime': _combineTime(_closeTimes[day]!),
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

  TimeOfDay _combineTime(TimeOfDay time) {
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}

// AuthWrapper to handle authentication state and navigate to appropriate pages
class AuthWrapper extends StatelessWidget {
  final Widget home;
  final Widget login;

  const AuthWrapper({required this.home, required this.login, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return home;
        }
        return login;
      },
    );
  }
}

// Sign out function
Future<void> signOut(BuildContext context) async {
  try {
    final auth = FirebaseAuth.instance;

    await auth.signOut();

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
