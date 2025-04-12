import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers for the text fields
  final TextEditingController _nameController =
      TextEditingController(); // Changed from _usernameController
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  // Add these variables
  Map<String, bool> _editingStates = {
    'username': false,
    'age': false,
    'income': false,
    'expense': false,
    'goal': false,
  };

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _nameController.dispose(); // Changed from _usernameController
    _ageController.dispose();
    _incomeController.dispose();
    _expenseController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3E5F5), // Light purple background
      body: SafeArea(
        child: Column(
          children: [
            // Top section with title and home icon
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Profile',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // Go back to home page
                      },
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content area with blue border
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color.fromARGB(255, 144, 198, 243),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Profile picture
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_outline,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Form fields
                        _buildEditableField('Name', _nameController,
                            'username'), // Changed from 'Username'
                        const SizedBox(height: 12),
                        _buildEditableField('Age', _ageController, 'age',
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        _buildEditableField(
                            'Monthly Income', _incomeController, 'income',
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        _buildEditableField(
                            'Fixed Expense', _expenseController, 'expense',
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        _buildEditableField(
                            'Financial Goal', _goalController, 'goal'),

                        const Spacer(),

                        // Save button
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextButton(
                            onPressed: () {
                              // Save profile logic would go here
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile saved successfully!'),
                                ),
                              );
                            },
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom navigation bar
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavBarItem(Icons.person, isSelected: true),
                  _buildNavBarItem(Icons.swap_horiz),
                  _buildNavBarItem(Icons.block),
                  _buildNavBarItem(Icons.settings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build input fields
  Widget _buildInputField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xFFFCE4EC), // Light pink
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // Helper method to build bottom navigation bar items
  Widget _buildNavBarItem(IconData icon, {bool isSelected = false}) {
    return Container(
      width: 60,
      height: 60,
      child: Icon(
        icon,
        color:
            isSelected ? Colors.black : const Color.fromARGB(255, 67, 170, 112),
        size: 30,
      ),
    );
  }

  // Helper method to build editable input field
  Widget _buildEditableField(
      String label, TextEditingController controller, String fieldKey,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _editingStates[fieldKey] == true
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      hintText: label,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black87),
                    ),
                  )
                : Text(
                    controller.text.isEmpty ? label : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Colors.black87
                          : Colors.black,
                    ),
                  ),
          ),
          IconButton(
            icon: Icon(
              _editingStates[fieldKey] == true ? Icons.check : Icons.edit,
              color: Colors.purple,
            ),
            onPressed: () async {
              if (_editingStates[fieldKey] == true) {
                // Save the changes
                await _updateField(fieldKey);
              }
              setState(() {
                _editingStates[fieldKey] = !_editingStates[fieldKey]!;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateField(String fieldKey) async {
    try {
      final response = await AuthService.updateProfile(
        userId: widget.userId, // Use the userId passed to widget
        data: {
          'name': _nameController.text,
          'age': int.tryParse(_ageController.text),
          'monthlyIncome': double.tryParse(_incomeController.text),
          'fixedExpense': double.tryParse(_expenseController.text),
          'financialGoal': _goalController.text,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }
}
