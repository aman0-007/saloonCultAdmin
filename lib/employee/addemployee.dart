import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saloon_cult_admin/Authentication/authentication.dart';
import 'package:saloon_cult_admin/colors.dart';

class EmployeeForm extends StatefulWidget {
  final Authentication employeeService;

  const EmployeeForm({super.key, required this.employeeService});

  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _profileImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_profileImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ClipOval(
                  child: Image.file(
                    _profileImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_camera, color: Colors.white),
              label: const Text('Select Profile Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 20.0),
            _buildTextField(
              controller: _nameController,
              label: 'Employee Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _mobileController,
              label: 'Mobile Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.employeeService.registerEmployeeWithEmailAndPassword(
                    context,
                    _nameController.text,
                    _mobileController.text,
                    _emailController.text,
                    _passwordController.text,
                    _profileImage!,
                  );
                  Navigator.pop(context); // Close the bottom sheet after submission
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
              child: const Text('Register Employee'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryYellow),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Email' && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}
