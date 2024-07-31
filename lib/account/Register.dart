import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saloon_cult_admin/Authentication/authentication.dart';
import 'package:saloon_cult_admin/colors.dart';
import 'package:saloon_cult_admin/location/getlocation.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Position? _currentPosition;
  String _selectedAddress = '';

  bool _isPasswordVisible = false;
  File? _profileImage;
  File? _bannerImage;
  final ImagePicker _picker = ImagePicker();
  final Authentication _authentication = Authentication();

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Container(
            width: deviceWidth * 0.85,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryYellow),
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.black,
            ),
            child: IntrinsicHeight(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10.0),
                    _buildTextField(
                      controller: _shopNameController,
                      hintText: 'Shop Name',
                    ),
                    const SizedBox(height: 10.0),
                    _buildImageUploadButton(
                      label: 'Upload Profile Image',
                      onPressed: () async {
                        await _pickImage((file) {
                          setState(() {
                            _profileImage = file;
                          });
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    _buildImageUploadButton(
                      label: 'Upload Banner Image',
                      onPressed: () async {
                        await _pickImage((file) {
                          setState(() {
                            _bannerImage = file;
                          });
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    _buildLocationButton(),
                    const SizedBox(height: 10.0),
                    _buildTextField(
                      controller: _address1Controller,
                      hintText: 'Address',
                    ),
                    const SizedBox(height: 10.0),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                    ),
                    const SizedBox(height: 10.0),
                    _buildPasswordField(),
                    const SizedBox(height: 20.0),
                    _buildRegisterButton(deviceWidth),
                    const SizedBox(height: 15.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(Function(File file) onImagePicked) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.primaryYellow.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2.0),
          borderRadius: BorderRadius.circular(5),
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        labelStyle: const TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildImageUploadButton({required String label, required Future<void> Function() onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.upload),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        minimumSize: const Size(double.infinity, 0),
      ),
    );
  }

  Widget _buildLocationButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GetLocation(),
          ),
        );
        if (result != null && result is Map) {
          setState(() {
            _currentPosition = Position(
              latitude: result['position'].latitude,
              longitude: result['position'].longitude,
              accuracy: 0.0, // provide an appropriate accuracy value
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
              timestamp: DateTime.now(),
              altitudeAccuracy: 0.0,
              headingAccuracy: 0.0,
            );
            _selectedAddress = result['selectedAddress'];
            _address1Controller.text = result['selectedAddress'];
          });
        }
      },
      icon: const Icon(Icons.location_on),
      label: const Text('Select Location'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        minimumSize: const Size(double.infinity, 0),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(color: AppColors.primaryYellow.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2.0),
              borderRadius: BorderRadius.circular(5),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.withOpacity(0.7),
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRegisterButton(double deviceWidth) {
    return ElevatedButton(
      onPressed: () async {
        String email = _emailController.text;
        String password = _passwordController.text;
        try {
          String shopName = _shopNameController.text;
          await _authentication.registerShopWithEmailAndPassword(
            context, shopName, _profileImage!, _bannerImage!, _currentPosition!, _selectedAddress, email, password,
          );

        } catch (e) {
          if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'email-already-in-use':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This email is already registered.')),
                );
                break;
              case 'invalid-email':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid email address.')),
                );
                break;
              default:
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registration failed. Please try again later.')),
                );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration failed.')),
            );
            print(e);
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        minimumSize: Size(deviceWidth * 0.55, 0),
      ),
      child: const Text(
        'Register',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
