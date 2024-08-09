import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saloon_cult_admin/colors.dart';
import 'package:saloon_cult_admin/drawer/drawer.dart';
import 'package:saloon_cult_admin/menu/addmenu.dart';
import 'package:saloon_cult_admin/menu/updatemenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuManagement extends StatefulWidget {
  const MenuManagement({super.key});

  @override
  State<MenuManagement> createState() => _MenuManagementState();
}

class _MenuManagementState extends State<MenuManagement> {
  late Future<List<Map<String, dynamic>>> _menuItemsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _fetchMenuItems(); // Fetch menu items on initialization
  }

  Future<List<Map<String, dynamic>>> _fetchMenuItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      QuerySnapshot menuSnapshot = await FirebaseFirestore.instance
          .collection('shops')
          .doc(userId)
          .collection('menu')
          .get();

      return menuSnapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      })
          .toList();
    } else {
      throw Exception('No logged-in user found');
    }
  }

  Future<void> _deleteMenuItem(String docId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(userId)
          .collection('menu')
          .doc(docId)
          .delete();
      setState(() {
        _menuItemsFuture = _fetchMenuItems(); // Refresh menu items
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu item deleted successfully')),
      );
    }
  }

  void _showEditMenuDialog(BuildContext context, String docId, Map<String, dynamic> menuItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Menu Item',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.primaryYellow),
                  ),
                  const SizedBox(height: 16.0),
                  UpdateMenuForm(
                    initialName: menuItem['menuName'],       // Pass existing name
                    initialPrice: menuItem['menuPrice'],     // Pass existing price
                    initialTime: menuItem['menuTime'],       // Pass existing time
                    onSave: (name, price, time) => _updateMenuItem(docId, name, price, time),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Future<void> _updateMenuItem(String docId, String name, String price, String time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(userId)
          .collection('menu')
          .doc(docId)
          .update({
        'menuName': name,
        'menuPrice': price,
        'menuTime': time,
      });
      setState(() {
        _menuItemsFuture = _fetchMenuItems(); // Refresh menu items
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu item updated successfully')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primaryYellow,
        title: const Text(
          'Manage Menu',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const DashboardDrawer(),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Search TextBox
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryYellow),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                ),
              ),
            ),
            // Display Menu Items
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _menuItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading menu items'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No menu items found'));
                  } else {
                    List<Map<String, dynamic>> menuItems = snapshot.data!;
                    List<Map<String, dynamic>> filteredMenuItems = menuItems.where((menuItem) {
                      String menuName = menuItem['menuName']?.toLowerCase() ?? '';
                      return menuName.contains(_searchQuery);
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredMenuItems.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> menuItem = filteredMenuItems[index];
                        return ListTile(
                          title: Text(menuItem['menuName'] ?? 'No Name'),
                          subtitle: Text('Price: ${menuItem['menuPrice']} | Time: ${menuItem['menuTime']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _showEditMenuDialog(context, menuItem['id'], menuItem);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteMenuItem(menuItem['id']);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryYellow,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _showAddMenuDialog(context);
        },
      ),
    );
  }

  void _showAddMenuDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to adjust its size based on keyboard
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjusts for keyboard height
          ),
          duration: const Duration(milliseconds: 300), // Smooth transition duration
          curve: Curves.easeInOut, // Smooth curve for padding adjustment
          child: SingleChildScrollView( // Ensures the whole form can move above the keyboard
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Adjust height based on content
                children: [
                  Text(
                    'Add Menu Item',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryYellow),
                  ),
                  const SizedBox(height: 16.0),
                  MenuForm(
                    onFormSubmitted: () {
                      setState(() {
                        _menuItemsFuture = _fetchMenuItems(); // Refresh menu items
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
