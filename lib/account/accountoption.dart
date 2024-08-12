import 'package:flutter/material.dart';
import 'package:saloon_cult_admin/account/Register.dart';
import 'package:saloon_cult_admin/account/login.dart';
import 'package:saloon_cult_admin/colors.dart';

class Accountoptionpage extends StatefulWidget {
  const Accountoptionpage({super.key});

  @override
  State<Accountoptionpage> createState() => _AccountoptionpageState();
}

class _AccountoptionpageState extends State<Accountoptionpage> {
  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black, // Changed background color to black
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: deviceWidth * 0.85, // 85% of device width
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryYellow), // Blue accent border
                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                    color: Colors.transparent, // Transparent body color
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Login Type",
                        style: TextStyle(color: AppColors.primaryYellow.withOpacity(0.8), fontSize: 18.0),
                      ),
                      const SizedBox(height: 10.0),
                      Divider(
                        color: AppColors.primaryYellow.withOpacity(0.5),
                        thickness: 1.0,
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: deviceWidth * 0.6, // Set button width to 60% of device width
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Login()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow, // Blue accent background
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0), // Circular button
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      SizedBox(
                        width: deviceWidth * 0.6, // Set button width to 60% of device width
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Register()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryYellow), // Blue accent border
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0), // Circular button
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          ),
                          child: const Text(
                            "Register",
                            style: TextStyle(color: AppColors.primaryYellow),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
