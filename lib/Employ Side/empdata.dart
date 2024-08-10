import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static final UserData _instance = UserData._internal();

  factory UserData() => _instance;

  UserData._internal();

  String? userName;
  String? profileImageUrl;
  String? shopId;
  static UserData get instance => _instance;

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('employees').doc(userId).get();

      if (userDoc.exists) {
        userName = userDoc['name'];
        profileImageUrl = userDoc['profileImage'];
        shopId = userDoc['shopId'];
      }
    }
  }
}
