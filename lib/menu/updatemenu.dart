import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saloon_cult_admin/colors.dart';

class UpdateMenuForm extends StatefulWidget {
  final String? initialName;
  final String? initialPrice;
  final String? initialTime;
  final Function(String name, String price, String time) onSave;

  const UpdateMenuForm({
    Key? key,
    this.initialName,
    this.initialPrice,
    this.initialTime,
    required this.onSave,
  }) : super(key: key);

  @override
  _UpdateMenuFormState createState() => _UpdateMenuFormState();
}

class _UpdateMenuFormState extends State<UpdateMenuForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  int _selectedHour = 1;
  int _selectedMinute = 5;

  List<int> hours = [0, 1, 2, 3, 4];
  List<int> minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _priceController = TextEditingController(text: widget.initialPrice ?? '');

    if (widget.initialTime != null) {
      final timeParts = widget.initialTime!.split(' ');
      _selectedHour = int.tryParse(timeParts[0].replaceAll('h', '')) ?? 1;
      _selectedMinute = int.tryParse(timeParts[1].replaceAll('m', '')) ?? 5;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      String time = '${_selectedHour}h ${_selectedMinute}m';
      widget.onSave(_nameController.text, _priceController.text, time);
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
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
              child: const Text('Update Menu Item'),
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

