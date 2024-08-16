import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permission
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User denied permission');
    }
  }

  // Get device token
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    if (token == null) {
      throw Exception('Failed to get device token');
    }
    return token;
  }

  // Handle token refresh
  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((newToken) {
      // Handle token refresh here
      print('Token refreshed: $newToken');
    });
  }

  // Send notification via HTTP POST
  Future<void> sendNotification({
    required String deviceToken,
    required String title,
    required String body,
  }) async {
    final String apiUrl = 'https://fcm.googleapis.com/v1/projects/saloonshop-5b880/messages:send';
    final String oauthToken = 'ya29.c.c0ASRK0GZeFwfEBJjjQSpvwJYzpGDbCsNIKhvIom3L5h89sbDcjLpa7Ks5tImQeULMDT-VRmj0OuciEg3CHNnIblaE0j4-CePBJEHbwZbaiu2h0Igzf-hvxMMP8O936WW044skCwabmQTAcKVxKJxdDqsvQh1mEqHb-DkOpfxpgTv4nxScVBXdr7TGr-ghksq6xjDMCFt2aJ7lL1mvLKKFkk9LF62P9gBtVRbIoQoM67KE1HwgE0y929AWCsOm81Ap7LDVAWEwYZx15TGnu-4o9DVtzENOkfdF8Qw4EKM9J_3nDOnry_ZA2IYJiimOEO2D_JynyI698iqB1EjRfMlu9fcIsl1J-wP7KIVG3LxsvwSLnFvpDxkSKOu7q31IemMo4Xl20wL399K6zcVyln0iWpBe12gk-c4hepdfluuJdx_O6r_zv5kI69FShQpzah82ycO5XiSI7uom1lp86whhZM8XMebQMFsXX1fySavq9h9W6vlX4SWyZzjqjSmna8itshQytkuaQ0688ux5RugX0QRs2vYZfrod2mF1Ri9zib8lUw_OwgqSUJ-mo8w7c7q2oqwVxptSRM4vOs1dj6plZ_jXbt_gOWObO_b_3uaz_OxdgjSbzO36Fzg62MSWBJ3gF16mosRo4rYfnaIokyxagjiZs-FgX1ktuSeyan-27UIVwckkUwvU3Sr_4O-nntvklJqZtI3Fjyv5SQ9kqSo13_wsveQYxSurUqgzsW7-_uvBoxxmtxIvf0oJ8S2yB7j4n5eFxSyVQrgpcJuRhq448Ywpffq1Oh8-m9ufrW8OWR4F732ObyJm6aY2RxOuWo98OVcQgg9ehuU7mXxyZ4tBYk4cZ0t0Vnjd9eXhy9kYnRM40fjuIiUVUjqamcISS3kmrSOks70Uaecf6ialXaefMQF7dRb9ikppeRh8210-F057VW8u-q4qvMfIFVb0i3ZuxzikOBv6mqBm9fZ1ak7s09nw9Xj04l6bUxddlB891ZQ4YsBt9OhzQvz';

    final Map<String, dynamic> data = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': title,
          'body': body,
        },
        'android': {
          'priority': 'high',
        },
        'apns': {
          'headers': {
            'apns-priority': '10',
          },
        },
      },
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $oauthToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully: ${response.body}');
    } else {
      print('Failed to send notification: ${response.statusCode}, ${response.body}');
    }
  }
}