import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:saloon_cult_admin/Authentication/authentication.dart';
import 'package:saloon_cult_admin/colors.dart';

class MenuForm extends StatefulWidget {
  final VoidCallback onFormSubmitted; // Callback for form submission

  const MenuForm({Key? key, required this.onFormSubmitted}) : super(key: key);

  @override
  _MenuFormState createState() => _MenuFormState();
}

class _MenuFormState extends State<MenuForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final Authentication auth = Authentication();

  int _selectedHour = 0;
  int _selectedMinute = 30;

  List<int> hours = [0, 1, 2, 3, 4];
  List<int> minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Menu Name',
              icon: Icons.fastfood,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _priceController,
              label: 'Price',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: _buildPickerBox(
                    label: 'Hours',
                    value: _selectedHour,
                    items: hours,
                    onChanged: (value) {
                      setState(() {
                        _selectedHour = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildPickerBox(
                    label: 'Minutes',
                    value: _selectedMinute,
                    items: minutes,
                    onChanged: (value) {
                      setState(() {
                        _selectedMinute = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  String time = '${_selectedHour}h ${_selectedMinute}m';
                  auth.addShopMenuItem(
                    context,
                    _nameController.text,
                    _priceController.text,
                    time,
                  ).then((_) {
                    widget.onFormSubmitted(); // Call the callback
                    Navigator.pop(context); // Close the bottom sheet after submission
                  }).catchError((error) {
                    // Handle errors if needed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add menu item')),
                    );
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
              child: const Text('Add Menu Item'),
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
        return null;
      },
    );
  }

  Widget _buildPickerBox({
    required String label,
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => _showPicker(label, items, value, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.primaryYellow, width: 2.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                  '$label: $value',
                  style: const TextStyle(fontSize: 16.0, color: AppColors.primaryYellow),
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.primaryYellow),
          ],
        ),
      ),
    );
  }

  void _showPicker(
      String label,
      List<int> items,
      int currentValue,
      ValueChanged<int?> onChanged,
      ) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.only(top: 10),
          color: Colors.white,
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryYellow,
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(initialItem: items.indexOf(currentValue)),
                  onSelectedItemChanged: (index) {
                    onChanged(items[index]);
                  },
                  children: items.map((item) => Center(child: Text('$item'))).toList(),
                ),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
